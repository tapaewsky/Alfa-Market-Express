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
    var baseURL: String = BaseURL.alfa + "products/"

    func resetData() {
        products.removeAll()
        baseURL = BaseURL.alfa + "products/"
    }

    func fetchProducts(completion: @escaping (Bool) -> Void) {
        guard !isLoading else {
            print("Загрузка уже выполняется")
            completion(false)
            return
        }

        isLoading = true
        isError = false

        guard let url = URL(string: baseURL) else {
            print("Неверный URL")
            isLoading = false
            completion(false)
            return
        }

        var request = URLRequest(url: url)

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            defer { self?.isLoading = false }

            if let error {
                print("Ошибка при загрузке данных: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self?.isError = true
                    completion(false)
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("Нет HTTP-ответа")
                DispatchQueue.main.async {
                    self?.isError = true
                    completion(false)
                }
                return
            }

            if httpResponse.statusCode == 401 {
                self?.authManager.refreshAccessToken { success in
                    if success {
                        self?.fetchProducts(completion: completion)
                    } else {
                        DispatchQueue.main.async {
                            self?.isError = true
                            completion(false)
                        }
                    }
                }
                return
            }

            guard let data else {
                print("Нет данных в ответе")
                DispatchQueue.main.async {
                    self?.isError = true
                    completion(false)
                }
                return
            }

            do {
                let response = try JSONDecoder().decode(ProductResponse.self, from: data)
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }

                    self.products.append(contentsOf: response.results)
                    self.baseURL = response.next ?? self.baseURL
                    print("Следующий URL: \(self.baseURL)")

                    completion(true)
                }
            } catch {
                print("Ошибка декодирования: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self?.isError = true
                    completion(false)
                }
            }
        }.resume()
    }
}
