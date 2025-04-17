//
//  ProductVM.swift
//  AlfaMarketExpress
//
//  Created by Said Tapaev on 24.12.2024.
//

import Combine
import Foundation

class ProductViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var isLoading = false
    @Published var isError = false

    private let authManager = AuthManager.shared
    private var currentCategoryID: Int?
    var nextPageURL: String?

    var defaultBaseURL: String {
        BaseURL.alfa + "products/"
    }

    func resetData() {
        products.removeAll()
        nextPageURL = nil
        currentCategoryID = nil
    }

    func fetchProducts(for category: Category? = nil, completion: @escaping (Bool) -> Void) {
        guard !isLoading else {
            print("🔄 Загрузка уже выполняется, отмена нового запроса")
            completion(false)
            return
        }

        isLoading = true
        isError = false

        // если это новый запрос, сбрасываем
        if let category = category {
            if currentCategoryID != category.id {
                resetData()
                currentCategoryID = category.id
            }
        }

        let urlString: String

        if let next = nextPageURL {
            urlString = next
            print("📡 Загрузка следующей страницы: \(urlString)")
        } else if let catID = currentCategoryID, catID != 0 {
            urlString = "\(defaultBaseURL)?category=\(catID)"
            print("📡 Загрузка товаров категории ID \(catID): \(urlString)")
        } else {
            urlString = defaultBaseURL
            print("📡 Загрузка всех товаров: \(urlString)")
        }

        guard let url = URL(string: urlString) else {
            print("❌ Неверный URL: \(urlString)")
            isLoading = false
            completion(false)
            return
        }

        var request = URLRequest(url: url)

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            defer { self?.isLoading = false }

            if let error {
                print("❌ Ошибка при загрузке данных: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self?.isError = true
                    completion(false)
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Нет HTTP-ответа")
                DispatchQueue.main.async {
                    self?.isError = true
                    completion(false)
                }
                return
            }

            print("✅ Ответ сервера: \(httpResponse.statusCode)")

            if httpResponse.statusCode == 401 {
                print("🔐 Токен просрочен, обновляем...")
                self?.authManager.refreshAccessToken { success in
                    if success {
                        print("🔄 Повтор запроса после обновления токена")
                        self?.fetchProducts(for: category, completion: completion)
                    } else {
                        print("❌ Не удалось обновить токен")
                        DispatchQueue.main.async {
                            self?.isError = true
                            completion(false)
                        }
                    }
                }
                return
            }

            guard let data else {
                print("❌ Нет данных в ответе")
                DispatchQueue.main.async {
                    self?.isError = true
                    completion(false)
                }
                return
            }

            do {
                let response = try JSONDecoder().decode(ProductResponse.self, from: data)
                DispatchQueue.main.async {
                    print("📦 Получено товаров: \(response.results.count)")
                    print("➡️ Следующая страница: \(response.next ?? "nil")")

                    let existingIDs = Set(self?.products.map(\.id) ?? [])
                    let newProducts = response.results.filter { !existingIDs.contains($0.id) }
                    self?.products.append(contentsOf: newProducts)
                    self?.nextPageURL = response.next
                    completion(true)
                
                
                }
            } catch {
                print("❌ Ошибка декодирования: \(error.localizedDescription)")
                if let rawString = String(data: data, encoding: .utf8) {
                    print("📨 Ответ сервера: \(rawString)")
                }
                DispatchQueue.main.async {
                    self?.isError = true
                    completion(false)
                }
            }
        }.resume()
    }
}
