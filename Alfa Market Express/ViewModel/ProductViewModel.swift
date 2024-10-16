//
//  ProductViewModel.swift
//  WareHouse1
//
//  Created by Said Tapaev on 06.07.2024.
//
import Combine
import Foundation
import SwiftUI

class ProductViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var isLoading = false
    @Published var isError = false
    @Published var searchText: String = ""
    
    private let productsKey = "cachedProducts"
    private let networkMonitor = NetworkMonitor()
    
    // MARK: - Base URL
    private let baseURL = "http://95.174.90.162:60/api/products/"
    
    // MARK: - Initialization
    init() {
        loadProducts()
        fetchData { success in
            if !success {
                self.loadProducts()
            }
        }
    }
    
    // MARK: - Data Fetching
    func fetchData(completion: @escaping (Bool) -> Void) {
        guard networkMonitor.isConnected else {
            print("No internet connection")
            completion(false)
            return
        }
        
        isLoading = true
        isError = false
        
        let dispatchGroup = DispatchGroup()
        var success = true
        
        dispatchGroup.enter()
        fetchProducts { fetchProductsSuccess in
            success = success && fetchProductsSuccess
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            self.isLoading = false
            self.isError = !success
            completion(success)
        }
    }
    
    func fetchProducts(completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: baseURL) else {
            print("Invalid URL")
            completion(false)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching products: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }
            
            guard let data = data else {
                print("No data received")
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }
            
            do {
                let products = try JSONDecoder().decode([Product].self, from: data)
                DispatchQueue.main.async {
                    self.products = products
                    self.saveProducts()
                    completion(true)
                }
            } catch {
                print("Error decoding products: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }.resume()
    }
    
    func searchProducts(query: String, completion: @escaping (Bool) -> Void) {
        guard !query.isEmpty else {
            completion(false)
            return
        }
        
        let searchUrl = "\(baseURL)?search=\(query)"
        
        // Создаем URL с проверкой
        guard let encodedUrlString = searchUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encodedUrlString) else {
            print("Invalid search URL")
            completion(false)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            // Проверка на наличие ошибок
            if let error = error {
                print("Error searching products: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }
            
            // Проверка на корректность ответа
            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                print("Error: HTTP status code \(httpResponse.statusCode)")
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }
            
            // Проверка данных
            guard let data = data else {
                print("No data received")
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }
            
            // Декодируем данные
            do {
                let products = try JSONDecoder().decode([Product].self, from: data)
                DispatchQueue.main.async {
                    self.products = products
                    self.saveProducts() // Сохраняем кэшированные продукты
                    completion(true)
                }
            } catch {
                print("Error decoding search results: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }.resume()
    }
    
    // MARK: - Caching Products
    private func saveProducts() {
        // Сохраняем продукты с обработкой ошибок
        do {
            let data = try JSONEncoder().encode(products)
            UserDefaults.standard.set(data, forKey: productsKey)
        } catch {
            print("Error saving products: \(error.localizedDescription)")
        }
    }
    
    private func loadProducts() {
        // Загрузка продуктов с обработкой ошибок
        if let data = UserDefaults.standard.data(forKey: productsKey) {
            do {
                let savedProducts = try JSONDecoder().decode([Product].self, from: data)
                self.products = savedProducts
            } catch {
                print("Error loading cached products: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Filtered Products
    var filteredProducts: [Product] {
        if searchText.isEmpty {
            return products
        } else {
            return products.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
}
