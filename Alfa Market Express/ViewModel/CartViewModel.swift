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
//    let cartProduct: CartProduct
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
    var dataId: Int = 0
    
    private let cartKey = "cachedCart"
    private let baseURL = "http://95.174.90.162:60/api/cart/"
    
    private var authManager = AuthManager.shared
    
    init() {
        loadCart()
        updateSelectedTotalPrice()
    }
    
    func fetchCartData() async {
        guard let url = URL(string: baseURL) else { return }
        
        var token = authManager.accessToken
        if token == nil {
            await refreshAuthToken()
            token = authManager.accessToken
            if token == nil { return }
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token!)", forHTTPHeaderField: "Authorization")
        
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
    
    func addToCart(_ product: Product, quantity: Int) async {
        guard let url = URL(string: "\(baseURL)add/") else {
            print("Неверный URL")
            return
        }
        
        var token = authManager.accessToken
        if token == nil {
            await refreshAuthToken()
            token = authManager.accessToken
            if token == nil { return }
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token!)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["product": product.id, "quantity": quantity]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                print("Код статуса HTTP: \(httpResponse.statusCode)")
            }
            print("Полученные данные: \(String(data: data, encoding: .utf8) ?? "Нет данных")")
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                      let id = json["id"] as? Int {
                       // Сохраняем id в переменную
                       dataId = id
                       print("ID товара в корзине: \(id)")
                   } else {
                       print("Не удалось декодировать данные")
                   }
        } catch {
            print("Ошибка при добавлении в корзину: \(error.localizedDescription)")
        }
    }
    
    func updateProductQuantity(_ product: Product, newQuantity: Int) async {
        guard let url = URL(string: "\(baseURL)update/\(product.id)/") else { return }
        
        var token = authManager.accessToken
        if token == nil {
            await refreshAuthToken()
            token = authManager.accessToken
            if token == nil { return }
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("Bearer \(token!)", forHTTPHeaderField: "Authorization")
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
    
    func removeFromCart(_ product: Product) async {
        print (dataId)
        guard let url = URL(string: "\(baseURL)delete/\(dataId)/") else {
            print("Ошибка: Неверный URL")
            return
        }
        
        var token = authManager.accessToken
        if token == nil {
            print("Токен не найден, пытаемся обновить...")
            await refreshAuthToken()
            token = authManager.accessToken
            if token == nil {
                print("Ошибка: Не удалось получить токен")
                return
            }
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token!)", forHTTPHeaderField: "Authorization")
        print("Отправляем запрос DELETE на URL: \(url)")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
                print("HTTP Headers: \(httpResponse.allHeaderFields)")
            }
            
            print("Товар с ID \(product.id) успешно удален из корзины")
            DispatchQueue.main.async {
                self.cart.removeAll { $0.id == product.id }
                self.saveCart()
                print("Корзина обновлена: товар с ID \(product.id) удален")
            }
        } catch {
            print("Ошибка при удалении товара из корзины: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.isError = true
                print("Установлен флаг ошибки")
            }
        }
    }
    
    func selectAllProducts(_ selectAll: Bool) {
        for product in cart {
            selectedProducts[product.id] = selectAll
        }
        updateSelectedTotalPrice()
    }
    
    func toggleProductSelection(_ product: Product) {
        if let isSelected = selectedProducts[product.id], isSelected {
            selectedProducts[product.id] = false
        } else {
            selectedProducts[product.id] = true
        }
        updateSelectedTotalPrice()
    }
    
    func isInCart(_ product: Product) -> Bool {
        return cart.contains(where: { $0.id == product.id })
    }
    
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
    
    func refreshAuthToken() {
        authManager.refreshAccessToken { success in
            if success {
                print("Токен успешно обновлен")
            } else {
                print("Не удалось обновить токен")
            }
        }
    }
}
