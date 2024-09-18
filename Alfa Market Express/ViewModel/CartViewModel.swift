//
//  CartViewModel.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 09.09.2024.
//
import Foundation
import Combine

class CartViewModel: ObservableObject {
    @Published var cartItems: [CartProduct] = []
    @Published var cart: [Product] = [] {
        didSet {
            saveCart()
            updateSelectedTotalPrice()
        }
    }
    @Published var totalPrice: Double = 0.0
    @Published var selectedTotalPrice: Double = 0.0
    @Published var isLoading = false
    @Published var isError = false
    @Published var selectedProducts: [Int: Bool] = [:]
    
    private let cartKey = "cachedCart"
    private let baseURL = "http://192.168.1.7:8000/api/cart/"
    
    private var authManager = AuthManager.shared
    
    init() {
        loadCart()
        updateSelectedTotalPrice()
    }
    
    // MARK: - API calls
    
    // Fetch cart data
    func fetchCartData() async {
        guard let url = URL(string: baseURL) else { return }
        guard let token = authManager.accessToken else {
            // Если токена нет, нужно обновить токен
            await refreshAuthToken()
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let cartProducts = try JSONDecoder().decode([CartProduct].self, from: data)
            DispatchQueue.main.async {
                self.cartItems = cartProducts
                self.cart = cartProducts.map { $0.product }
                self.saveCart()
            }
        } catch {
            DispatchQueue.main.async {
                self.isError = true
            }
        }
    }
    
    // Fetch cart items from API
    func fetchCartItems() async {
        guard let url = URL(string: baseURL) else { return }
        guard let token = authManager.accessToken else {
            await refreshAuthToken()
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let cartProducts = try JSONDecoder().decode([CartProduct].self, from: data)
            DispatchQueue.main.async {
                self.cartItems = cartProducts
                self.cart = cartProducts.map { $0.product }
                self.saveCart()
            }
        } catch {
            DispatchQueue.main.async {
                self.isError = true
            }
        }
    }
    
    // Add product to cart
    func addToCart(_ product: Product, quantity: Int) async {
        guard let url = URL(string: "\(baseURL)add/") else {
            print("Неверный URL")
            return
        }
        
        guard let token = authManager.accessToken else {
            print("Токен доступа отсутствует. Попытка обновления токена...")
            await refreshAuthToken()
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["product_id": product.id, "quantity": quantity]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        print("Отправка запроса на \(url) с токеном: \(token)")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                print("Код статуса HTTP: \(httpResponse.statusCode)")
            }
            print("Полученные данные: \(String(data: data, encoding: .utf8) ?? "Нет данных")")
        } catch {
            print("Ошибка при добавлении в корзину: \(error.localizedDescription)")
        }
    }
    
    
    
    // Update product quantity
    func updateProductQuantity(_ product: Product, newQuantity: Int) async {
        guard let url = URL(string: "\(baseURL)update/\(product.id)/") else { return }
        guard let token = authManager.accessToken else {
            await refreshAuthToken()
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["quantity": newQuantity]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let updatedProduct = try JSONDecoder().decode(CartProduct.self, from: data)
            DispatchQueue.main.async {
                if let index = self.cart.firstIndex(where: { $0.id == updatedProduct.product.id }) {
                    self.cart[index].quantity = updatedProduct.quantity
                }
                self.saveCart()
            }
        } catch {
            DispatchQueue.main.async {
                self.isError = true
            }
        }
    }
    
    // Remove product from cart
    func removeFromCart(_ product: Product) async {
        guard let url = URL(string: "\(baseURL)delete/\(product.id)/") else { return }
        guard let token = authManager.accessToken else {
            await refreshAuthToken()
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (_, _) = try await URLSession.shared.data(for: request)
            DispatchQueue.main.async {
                self.cart.removeAll { $0.id == product.id }
                self.saveCart()
            }
        } catch {
            DispatchQueue.main.async {
                self.isError = true
            }
        }
    }
    
    // Select or deselect all products
    func selectAllProducts(_ selectAll: Bool) {
        for product in cart {
            selectedProducts[product.id] = selectAll
        }
        updateSelectedTotalPrice()
    }
    
    // Toggle product selection
    func toggleProductSelection(_ product: Product) {
        if let isSelected = selectedProducts[product.id], isSelected {
            selectedProducts[product.id] = false
        } else {
            selectedProducts[product.id] = true
        }
        updateSelectedTotalPrice()
    }
    
    // Check if product is in cart
    func isInCart(_ product: Product) -> Bool {
        return cart.contains(where: { $0.id == product.id })
    }
    
    // Update total price of selected products
    func updateSelectedTotalPrice() {
        selectedTotalPrice = cart.reduce(0) { total, product in
            if selectedProducts[product.id] == true {
                return total + (Double(product.price) ?? 0) * Double(product.quantity)
            }
            return total
        }
    }
    
    private func saveCart() {
        if let data = try? JSONEncoder().encode(cart) {
            UserDefaults.standard.set(data, forKey: cartKey)
        }
    }
    
    private func loadCart() {
        if let data = UserDefaults.standard.data(forKey: cartKey),
           let savedCart = try? JSONDecoder().decode([Product].self, from: data) {
            cart = savedCart
        }
    }
    
    // Refresh auth token if needed
    func refreshAuthToken() async {
        guard let refreshToken = authManager.refreshToken else {
            print("Refresh токен отсутствует")
            return
        }
        
        let url = URL(string: "\(baseURL)refresh-token/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["refresh_token": refreshToken]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        print("Отправка запроса на обновление токена с refresh токеном: \(refreshToken)")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                print("Код статуса HTTP: \(httpResponse.statusCode)")
            }
            if let dataString = String(data: data, encoding: .utf8) {
                print("Полученные данные при обновлении токена: \(dataString)")
            }
            
            // Обработка ответа для обновления токенов
            // Предположим, что ответ содержит новые токены
            // let newTokens = try JSONDecoder().decode(Tokens.self, from: data)
            // authManager.updateTokens(newTokens)
            
            print("Обновление токена успешно")
        } catch {
            print("Ошибка при обновлении токена: \(error.localizedDescription)")
        }
    }
}

