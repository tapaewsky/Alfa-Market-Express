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
    @Published var selectedProducts: Set<Product> = []
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
            partialResult + item.price
        }
        return String(format: "%.f ₽", total)
    }
    
    // Функция для добавления продукта в выбранные
    func selectProduct(_ product: Product) {
        selectedProducts.insert(product)
    }
    
    // Функция для удаления продукта из выбранных
    func deselectProduct(_ product: Product) {
        selectedProducts.remove(product)
    }
    
    // Функция для переключения состояния выбора продукта
    func toggleProductSelection(_ product: Product) {
        if selectedProducts.contains(product) {
            deselectProduct(product)
        } else {
            selectProduct(product)
        }
    }
    
    // Функция для удаления выбранных продуктов
    func removeSelectedProducts() {
        for product in selectedProducts {
            removeFromFavorites(product)
            removeFromCart(product)
        }
        selectedProducts.removeAll()
    }
    
    // Функция для добавления выбранных продуктов в корзину
    func addSelectedProductsToCart() {
        for product in selectedProducts {
            addToCart(product)
        }
        selectedProducts.removeAll()
    }

    // Функция для загрузки данных с сервера
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
    
    // Функция для загрузки продуктов с сервера
    func fetchProducts(completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "http://95.174.90.162:8000/api/products/") else {
            completion(false)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching products: \(error.localizedDescription)")
                completion(false)
                return
            }

            guard let data = data else {
                print("No data received")
                completion(false)
                return
            }

            // Печать ответа для отладки
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Received JSON: \(jsonString)")
            }
            
            do {
                let products = try JSONDecoder().decode([Product].self, from: data)
                DispatchQueue.main.async {
                    self.products = products
                    completion(true)
                }
            } catch {
                print("Error decoding products: \(error.localizedDescription)")
                completion(false)
            }
        }.resume()
    }
    
    // Функция для загрузки категорий с сервера
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
                print("No data received")
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
    
    // Сохранение продуктов
    private func saveProducts() {
        if let data = try? JSONEncoder().encode(products) {
            UserDefaults.standard.set(data, forKey: productsKey)
        }
    }
    
    // Сохранение категорий
    private func saveCategories() {
        if let data = try? JSONEncoder().encode(categories) {
            UserDefaults.standard.set(data, forKey: categoriesKey)
        }
    }
    
    // Сохранение избранных продуктов
    private func saveFavorites() {
        if let data = try? JSONEncoder().encode(favorites) {
            UserDefaults.standard.set(data, forKey: favoritesKey)
        }
    }
    
    // Сохранение корзины
    private func saveCart() {
        if let data = try? JSONEncoder().encode(cart) {
            UserDefaults.standard.set(data, forKey: cartKey)
        }
    }
    
    // Загрузка данных из UserDefaults
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
    
    // Фильтрация продуктов
    var filteredProducts: [Product] {
        if searchText.isEmpty {
            return products
        } else {
            return products.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    // Добавление в избранное
    func addToFavorites(_ product: Product) {
        if !favorites.contains(where: { $0.id == product.id }) {
            favorites.append(product)
        }
    }
    
    // Удаление из избранного
    func removeFromFavorites(_ product: Product) {
        if let index = favorites.firstIndex(where: { $0.id == product.id }) {
            favorites.remove(at: index)
        }
    }
    
    // Проверка на избранное
    func isFavorite(_ product: Product) -> Bool {
        return favorites.contains(where: { $0.id == product.id })
    }
    
    // Удаление из корзины
    func removeFromCart(_ product: Product) {
        if let index = cart.firstIndex(where: { $0.id == product.id }) {
            cart.remove(at: index)
        }
    }
    
    // Добавление в корзину
    func addToCart(_ product: Product) {
        cart.append(product)
    }
    
    // Переключение избранного
    func toggleFavorite(_ product: Product) {
        if isFavorite(product) {
            removeFromFavorites(product)
        } else {
            addToFavorites(product)
        }
        
        if let productIndex = products.firstIndex(where: { $0.id == product.id }) {
            products[productIndex].isFavorite.toggle()
        }
    }
    
    // Обновление продукта
    func updateProduct(_ product: Product) {
        if let index = products.firstIndex(where: { $0.id == product.id }) {
            products[index] = product
        }
    }
    
    // Симуляция добавления в избранное
    func simulateFavorites() {
        if !products.isEmpty {
            favorites.append(products[0])
            products[0].isFavorite = true
        }
    }
    
    // Загрузка изображения по URL
    func loadImage(for url: String, completion: @escaping (UIImage?) -> Void) {
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
            
            DispatchQueue.main.async {
                completion(image)
            }
        }.resume()
    }
}
