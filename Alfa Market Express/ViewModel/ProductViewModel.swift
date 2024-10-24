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
    
//    func reset() {
//        products.removeAll()
//           print("ProductViewModel reset")
//       }
    
    func fetchProducts(completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: baseURL) else {
            print("Неверный URL")
            completion(false)
            return
        }
        var request = URLRequest(url: url)
        
        guard let token = authManager.accessToken else {
            print("Токен доступа не найден, обновляем токен")
            authManager.refreshAccessToken { [weak self] success in
                if success {
                    self?.fetchProducts(completion: completion)
                } else {
                    self?.isLoading = false
                    self?.isError = true
                    completion(false)
                }
            }
            return
        }
        
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
                self?.isError = true
                DispatchQueue.main.async {
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
                self?.isError = true
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }.resume()
    }
}
