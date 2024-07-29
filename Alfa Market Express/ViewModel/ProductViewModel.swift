//
//  ProductViewModel.swift
//  WareHouse1
//
//  Created by Said Tapaev on 06.07.2024.
//
import Combine
import Foundation
import UIKit

class ProductViewModel: ObservableObject {
    @Published var products: [Product] = [] {
        didSet {
            saveProducts()
        }
    }
    @Published var categories: [Category] = [] {
        didSet {
            saveCategories()
        }
    }
    @Published var favorites: [Product] = [] {
        didSet {
            saveFavorites()
        }
    }
    @Published var cart: [Product] = [] {
        didSet {
            saveCart()
        }
    }
    @Published var searchText: String = ""
    @Published var isLoading = false
    @Published var isError = false

    private let productsKey = "cachedProducts"
    private let categoriesKey = "cachedCategories"
    private let favoritesKey = "cachedFavorites"
    private let cartKey = "cachedCart"
    
    init() {
        loadCachedData()
        fetchData { success in
            if !success {
                self.loadCachedData()
            }
        }
    }
    
    var totalPrice: String {
        let total = cart.reduce(0) { partialResult, item in
            partialResult + (Double(item.price) ?? 0)
        }
        return String(format: "%.f ₽", total)
    }
    
    func fetchData(completion: @escaping (Bool) -> Void) {
        isLoading = true
        isError = false
        
        let dispatchGroup = DispatchGroup()
        var success = true
        
        dispatchGroup.enter()
        fetchProducts { fetchProductsSuccess in
            success = success && fetchProductsSuccess
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        fetchCategories { fetchCategoriesSuccess in
            success = success && fetchCategoriesSuccess
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            self.isLoading = false
            self.isError = !success
            completion(success)
        }
    }
    
    func fetchProducts(completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "http://95.174.90.162:8000/api/products/") else {
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
                print("Error decoding products: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }.resume()
    }
    
    func fetchCategories(completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "http://95.174.90.162:8000/api/categories/") else {
            completion(false)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching categories: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }
            
            do {
                let categories = try JSONDecoder().decode([Category].self, from: data)
                DispatchQueue.main.async {
                    self.categories = categories
                    completion(true)
                }
            } catch {
                print("Error decoding categories: \(error.localizedDescription)")
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
    
    private func saveCategories() {
        if let data = try? JSONEncoder().encode(categories) {
            UserDefaults.standard.set(data, forKey: categoriesKey)
        }
    }
    
    private func saveFavorites() {
        if let data = try? JSONEncoder().encode(favorites) {
            UserDefaults.standard.set(data, forKey: favoritesKey)
        }
    }
    
    private func saveCart() {
        if let data = try? JSONEncoder().encode(cart) {
            UserDefaults.standard.set(data, forKey: cartKey)
        }
    }
    
    private func loadCachedData() {
        if let productsData = UserDefaults.standard.data(forKey: productsKey),
           let cachedProducts = try? JSONDecoder().decode([Product].self, from: productsData) {
            products = cachedProducts
        }
        
        if let categoriesData = UserDefaults.standard.data(forKey: categoriesKey),
           let cachedCategories = try? JSONDecoder().decode([Category].self, from: categoriesData) {
            categories = cachedCategories
        }
        
        if let favoritesData = UserDefaults.standard.data(forKey: favoritesKey),
           let cachedFavorites = try? JSONDecoder().decode([Product].self, from: favoritesData) {
            favorites = cachedFavorites
        }
        
        if let cartData = UserDefaults.standard.data(forKey: cartKey),
           let cachedCart = try? JSONDecoder().decode([Product].self, from: cartData) {
            cart = cachedCart
        }
    }
    
    var filteredProducts: [Product] {
        if searchText.isEmpty {
            return products
        } else {
            return products.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    func addToFavorites(_ product: Product) {
        if !favorites.contains(where: { $0.id == product.id }) {
            favorites.append(product)
        }
    }
    
    func removeFromFavorites(_ product: Product) {
        if let index = favorites.firstIndex(where: { $0.id == product.id }) {
            favorites.remove(at: index)
        }
    }
    
    func isFavorite(_ product: Product) -> Bool {
        return favorites.contains(where: { $0.id == product.id })
    }
    
    func removeFromCart(_ product: Product) {
        if let index = cart.firstIndex(where: { $0.id == product.id }) {
            cart.remove(at: index)
        }
    }
    
    func addToCart(_ product: Product) {
        cart.append(product)
    }
    
    func toggleFavorite(_ product: Product) {
        if let index = favorites.firstIndex(where: { $0.id == product.id }) {
            favorites.remove(at: index)
        } else {
            favorites.append(product)
        }
        
        if let productIndex = products.firstIndex(where: { $0.id == product.id }) {
            products[productIndex].isFavorite.toggle()
        }
    }
    
    func simulateFavorites() {
        if !products.isEmpty {
            favorites.append(products[0])
            products[0].isFavorite = true
        }
    }
    
    func loadImage(for url: String, completion: @escaping (UIImage?) -> Void) {
        // Since we removed the image caching, we will always download the image
        guard let imageURL = URL(string: url) else {
            print("Invalid URL: \(url)")
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: imageURL) { data, response, error in
            if let error = error {
                print("Error fetching image: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                print("Invalid data or unable to create image.")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            // Return the image on the main thread
            DispatchQueue.main.async {
                completion(image)
            }
        }.resume()
    }
}
