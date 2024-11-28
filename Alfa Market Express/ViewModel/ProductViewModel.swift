//
//  ProductViewModel.swift
//  WareHouse1
//
//  Created by Said Tapaev on 06.07.2024.
//


import Combine
import Foundation

class ProductViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var isLoading = false
    @Published var isError = false
    private let authManager = AuthManager.shared
    var baseURL: String? = "http://95.174.90.162:60/api/products/"
    

    func fetchProducts(completion: @escaping (Bool) -> Void) {
        guard let accessToken = authManager.accessToken else {
            authManager.refreshAccessToken { [weak self] success in
                if success {
                    self?.fetchProducts(completion: completion)
                } else {
                    print("Не удалось обновить токен")
                    completion(false)
                }
            }
            return
        }
        
        guard !isLoading else {
            print("Загрузка уже выполняется")
            completion(false)
            return
        }
        
        isLoading = true
        isError = false
        
        let urlString = baseURL ?? "URL_для_первоначальной_загрузки"
        
        guard let url = URL(string: urlString) else {
            print("Неверный URL")
            isLoading = false
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            defer { self?.isLoading = false }
            
            if let error = error {
                print("Ошибка при загрузке данных: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self?.isError = true
                    completion(false)
                }
                return
            }
            
            // Проверка статуса ответа
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
            
            guard let data = data else {
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
                    guard let self = self else { return }
                    
                    self.products.append(contentsOf: response.results)
                    self.baseURL = response.next
                    print("Следующий URL: \(self.baseURL ?? "nil")")
                    
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
