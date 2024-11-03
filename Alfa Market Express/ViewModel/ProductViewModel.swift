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
    private let baseURL = "http://95.174.90.162:60/api/products/"
    
    func fetchProducts(completion: @escaping (Bool) -> Void) {
        guard !isLoading else {
            print("Загрузка уже выполняется")
            return
        }
        
        isLoading = true
        
        // Проверяем, есть ли access токен
        if (authManager.accessToken != nil) {
            // Если токен действителен, загружаем продукты
            loadProducts(completion: completion)
        } else {
            // Если токена нет, обновляем его
            print("Токен доступа не найден, обновляем токен")
            authManager.refreshAccessToken { [weak self] success in
                guard let self = self else { return }
                if success {
                    // После успешного обновления токена, получаем продукты
                    self.loadProducts(completion: completion)
                } else {
                    // Обработка ошибки обновления токена
                    self.isLoading = false
                    self.isError = true
                    completion(false)
                }
            }
        }
    }
    
    private func loadProducts(completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: baseURL) else {
            print("Неверный URL")
            isLoading = false
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        
        print("Запрос на сервер: \(url.absoluteString)")
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            defer { self?.isLoading = false }
            
            if let error = error {
                print("Ошибка при получении продуктов: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self?.isError = true
                    completion(false)
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
                let products = try JSONDecoder().decode([Product].self, from: data)
                DispatchQueue.main.async {
                    self?.products = products
                    completion(true)
                }
            } catch {
                print("Ошибка декодирования продуктов: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self?.isError = true
                    completion(false)
                }
            }
        }.resume()
    }
}
