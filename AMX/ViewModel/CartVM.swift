//
//  CartVM.swift
//  AlfaMarketExpress
//
//  Created by Said Tapaev on 24.12.2024.
//

import Foundation
import Combine

class CartViewModel: ObservableObject {
    @Published var cartProduct: [CartProduct] = []
    @Published var cart: [Product] = []
    @Published var selectedTotalPrice: Double = 0.0
    @Published var isLoading = false
    @Published var isError = false
    @Published var selectedProducts: [Int: Bool] = [:]
    @Published var selectedProduct: Product?
    @Published var dataId: Int = 0
    
    private let baseURL = "https://alfamarketexpress.ru/api/cart/"
    private var authManager = AuthManager.shared
    
    func fetchCart(completion: @escaping (Bool) -> Void) {
        guard let accessToken = authManager.accessToken else {
            print("Access token not found.")
            completion(false)
            return
        }
        
        guard let url = URL(string: baseURL) else {
            print("Invalid URL")
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        print("Запрос на сервер: \(url.absoluteString)")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                print("Error fetching cart: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }
            
            guard let data = data else {
                print("No data in response")
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Полученные данные JSON: \(jsonString)")
            }
            
            do {
                let cartProducts = try JSONDecoder().decode([CartProduct].self, from: data)
                DispatchQueue.main.async {
                    self.cartProduct = cartProducts
                    completion(true)
                }
            } catch {
                print("Error decoding cart: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }.resume()
    }
    
    func addToCart(_ product: Product, quantity: Int) async {
        guard let url = URL(string: "\(baseURL)add/") else {
            print("Invalid URL")
            return
        }
        
        var token = await getToken()
        guard token != nil else { return }
        
        var request = createRequest(url: url, method: "POST", token: token!)
        let body: [String: Any] = ["product": product.id, "quantity": quantity]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        print("Запрос на сервер: \(url.absoluteString)")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
            }
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let id = json["id"] as? Int {
                dataId = id
                print("Product ID in cart: \(id)")
            } else {
                print("Failed to decode data")
            }
        } catch {
            print("Error adding to cart: \(error.localizedDescription)")
        }
    }
    
    
    func updateProductQuantity(productId: Int, newQuantity: Int) async {
        guard let url = URL(string: "\(baseURL)update/\(productId)/") else {
            print("Некорректный URL")
            return
        }
        objectWillChange.send()
        let token = await getToken()
        guard token != nil else {
            print("Токен равен nil")
            return
        }
        
        var request = createRequest(url: url, method: "PATCH", token: token!)
        let body: [String: Any] = ["quantity": newQuantity]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        print("Запрос на сервер: \(url.absoluteString)")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                print("Получен HTTP-ответ: \(httpResponse.statusCode)")
                
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let cartItem = jsonResponse["cart_item"] as? [String: Any],
                   let product = cartItem["product"] as? [String: Any],
                   let quantity = cartItem["quantity"] as? Int,
                   let priceString = product["price"] as? String,
                   let price = Double(priceString) {
                    
                    DispatchQueue.main.async {
                        if let index = self.cartProduct.firstIndex(where: { $0.id == productId }) {
                            self.cartProduct[index].quantity = quantity
                        } else {
                            print("Product with ID \(productId) not found in cartProduct")
                        }
                    }
                } else {
                    print("Ошибка: структура данных не соответствует ожидаемой.")
                }
            } else {
                print("Ошибка: некорректный HTTP-ответ или код состояния")
            }
        } catch {
            print("Ошибка декодирования: \(error.localizedDescription)")
        }
    }
    // This function is used to delete a product from the cart
    func removeFromCard(_ product: Product) async {
        
        guard dataId != 0 else {
            return
        }
        
        guard let url = URL(string: "\(baseURL)delete/\(dataId)/") else {
            print("Error: Invalid URL")
            return
        }
        
        var token = await getToken()
        guard token != nil else {
            print("Error: Unable to get token")
            return
        }
        
        
        var request = createRequest(url: url, method: "DELETE", token: token!)
        
        print("Запрос на сервер: \(url.absoluteString)")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode == 204 {
                    print("Product successfully removed")
                } else {
                    print("Failed to remove product. Status code: \(httpResponse.statusCode)")
                }
            }
            
            if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                print("Response JSON: \(jsonResponse)")
            } else {
                print("Failed to parse response data")
            }
            
            DispatchQueue.main.async {
                self.cart.removeAll { $0.id == product.id }
            }
        } catch {
            print("Error removing product from cart: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.isError = true
            }
        }
    }
    
    // This function is used to delete a product from the cart by its ID
    func removeFromCart(productId: Int) async {
        print("Attempting to remove product with ID: \(productId)")
        
        guard let url = URL(string: "\(baseURL)delete/\(productId)/") else {
            print("Error: Invalid URL")
            return
        }
        
        
        
        var token = await getToken()
        guard token != nil else {
            print("Error: Unable to get token")
            return
        }
        
        print("Token received: \(token!)")
        
        var request = createRequest(url: url, method: "DELETE", token: token!)
        
        print("Запрос на сервер: \(url.absoluteString)")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode == 204 {
                } else {
                    print("Failed to remove product. Status code: \(httpResponse.statusCode)")
                }
            }
            
            if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            } else {
                print("Failed to parse response data")
            }
            
            DispatchQueue.main.async {
                self.cart.removeAll { $0.id == productId }
            }
        } catch {
            print("Error removing product from cart: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.isError = true
            }
        }
    }
    
    func clearSelection() {
        for product in cart {
            selectedProducts[product.id] = false
        }
    }
    
    func toggleProductSelection(_ product: Product) async {
        guard let index = cartProduct.firstIndex(where: { $0.product.id == product.id }) else { return }
        let isSelected = selectedProducts[product.id] ?? false
        selectedProducts[product.id] = !isSelected
        updateSelectedTotalPrice()
    }
    
    
    func updateSelectedTotalPrice() {
        let selectedProductsList = cartProduct.filter { selectedProducts[$0.id] ?? false }
        selectedTotalPrice = selectedProductsList.reduce(0) { total, product in
            let price = Double(product.product.price) ?? 0
            let quantity = product.quantity
            return total + (price * Double(quantity))
        }
    }
    
    func selectProductsForCheckout(products: [CartProduct]) async {
        guard let url = URL(string: "\(baseURL)select/") else {
            print("Invalid URL: \(baseURL)select/")
            return
        }
        
        var token = await getToken()
        guard token != nil else {
            print("Token not found, aborting checkout.")
            return
        }
        var request = createRequest(url: url, method: "POST", token: token!)
        print("Запрос на сервер: \(url.absoluteString)")
        for product in products {
        }
        
        do {
            let jsonData = try JSONEncoder().encode(products)
            request.httpBody = jsonData
            
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Received HTTP Status Code: \(httpResponse.statusCode)")
            }
            handleCheckoutResponse(data: data, response: response)
        } catch {
            print("Error during checkout request: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.isError = true
            }
        }
    }
    
    private func refreshAuthToken() {
        authManager.refreshAccessToken { success in
            if success {
                print("Token successfully refreshed")
            } else {
                print("Failed to refresh token")
            }
        }
    }
    
    func selectProduct(_ cartProduct: CartProduct) {
        selectedProducts[cartProduct.id] = true
    }
    
    func deselectProduct(_ cartProduct: CartProduct) {
        selectedProducts[cartProduct.id] = false
    }
    
    private func getToken() async -> String? {
        return authManager.accessToken
    }
    
    private func createRequest(url: URL, method: String, token: String) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
    
    private func handleCheckoutResponse(data: Data, response: URLResponse) {
        if let httpResponse = response as? HTTPURLResponse {
            print("HTTP Status Code: \(httpResponse.statusCode)")
        }
        
        if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
        } else {
            print("Failed to decode response data")
        }
    }
}
