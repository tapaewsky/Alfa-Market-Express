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
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Base URL
    private let baseURL = "http://95.174.90.162:60/api/products/"
    
    // MARK: - Initialization
    init() {
        loadProducts()
    }
    
    // MARK: - Load Products
    func loadProductsIfNeeded() {
        if products.isEmpty {
            fetchData()
        }
    }
    
    // MARK: - Data Fetching
    func fetchData() {
        print("Запрос продуктов из ProductViewModel")
        guard networkMonitor.isConnected else {
            print("No internet connection")
            isError = true
            return
        }
        
        isLoading = true
        isError = false
        
        fetchProducts()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                self.isLoading = false
                if case .failure = completion {
                    self.isError = true
                }
            }, receiveValue: { products in
                self.products = products
                self.saveProducts()
            })
            .store(in: &cancellables)
    }
    
    private func fetchProducts() -> AnyPublisher<[Product], Error> { 
        guard let url = URL(string: baseURL) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [Product].self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    func searchProducts(query: String) {
        guard !query.isEmpty else {
            return
        }
        
        let searchUrl = "\(baseURL)?search=\(query)"
        
        guard let encodedUrlString = searchUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encodedUrlString) else {
            print("Invalid search URL")
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [Product].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Error searching products: \(error.localizedDescription)")
                }
            }, receiveValue: { products in
                self.products = products
                self.saveProducts() // Сохраняем кэшированные продукты
            })
            .store(in: &cancellables)
    }
    
    // MARK: - Caching Products
    private func saveProducts() {
        do {
            let data = try JSONEncoder().encode(products)
            UserDefaults.standard.set(data, forKey: productsKey)
        } catch {
            print("Error saving products: \(error.localizedDescription)")
        }
    }
    
    private func loadProducts() {
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
