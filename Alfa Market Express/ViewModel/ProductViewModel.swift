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

    init() {
        loadProducts()
        fetchData { success in
            if !success {
                self.loadProducts()
            }
        }
    }
    
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
        guard let url = URL(string: "http://95.174.90.162:60/api/products/") else {
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

            let searchUrl = "http://95.174.90.162:60/api/products/?search=\(query)"
            guard let url = URL(string: searchUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else {
                completion(false)
                return
            }

            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("Error searching products: \(error.localizedDescription)")
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
    
    private func saveProducts() {
        if let data = try? JSONEncoder().encode(products) {
            UserDefaults.standard.set(data, forKey: productsKey)
        }
    }

    private func loadProducts() {
        if let data = UserDefaults.standard.data(forKey: productsKey),
           let savedProducts = try? JSONDecoder().decode([Product].self, from: data) {
            self.products = savedProducts
        }
    }

    var filteredProducts: [Product] {
        if searchText.isEmpty {
            return products
        } else {
            return products.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
}
