//
//  CartViewModel.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 09.09.2024.
//
import Foundation
import Combine

class CartViewModel: ObservableObject {
    // MARK: - Properties
    @Published var favoritesViewModel: FavoritesViewModel
    @Published var cartProduct: [CartProduct] = []
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
    @Published var selectedProduct: Product?
    private var dataId: Int = 0
    private let cartKey = "cachedCart"
    private let baseURL = "http://95.174.90.162:60/api/cart/"
    private var authManager = AuthManager.shared

    // MARK: - Initializer
    init(favoritesViewModel: FavoritesViewModel) {
        self.favoritesViewModel = favoritesViewModel
        loadCart()
    }
    
    // MARK: - API Calls
    func fetchCart(completion: @escaping (Bool) -> Void) {
        print("Запрос продуктов из CartViewModel")
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
            
            do {
                let cartProducts = try JSONDecoder().decode([CartProduct].self, from: data)
                DispatchQueue.main.async {
                    self.cartProduct = cartProducts
                    self.saveCart()
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

    func updateProductQuantity(_ product: Product, newQuantity: Int) async {
        guard let url = URL(string: "\(baseURL)update/\(product.id)/") else { return }
        
        var token = await getToken()
        guard token != nil else { return }
        
        var request = createRequest(url: url, method: "PATCH", token: token!)
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
        print("Attempting to remove product: \(product.name), ID: \(product.id)")

        // Проверяем, установлен ли dataId
        guard dataId != 0 else {
            print("Error: dataId is 0. Unable to remove product.")
            return
        }

        guard let url = URL(string: "\(baseURL)delete/\(dataId)/") else {
            print("Error: Invalid URL")
            return
        }

        print("URL to remove product: \(url)")

        var token = await getToken()
        guard token != nil else {
            print("Error: Unable to get token")
            return
        }

        print("Token received: \(token!)")

        var request = createRequest(url: url, method: "DELETE", token: token!)
        
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
                self.saveCart()
                print("Cart updated: product with ID \(product.id) removed")
            }
        } catch {
            print("Error removing product from cart: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.isError = true
            }
        }
    }

    
    // MARK: - Product Selection
    func selectAllProducts(_ selectAll: Bool) {
        for product in cartProduct {
            selectedProducts[product.id] = selectAll
        }
        print("Все продукты выбраны: \(selectAll)")
        updateSelectedTotalPrice()
    }

    func clearSelection() {
        for product in cart {
            selectedProducts[product.id] = false
        }
    }

    func toggleProductSelection(_ product: Product) {
        if let index = cartProduct.firstIndex(where: { $0.product.id == product.id }) {
            let isSelected = selectedProducts[product.id] ?? false
            selectedProducts[product.id] = !isSelected
            updateSelectedTotalPrice()
        }
    }

    func isInCart(_ product: Product) -> Bool {
        return cart.contains(where: { $0.id == product.id })
    }

    func updateSelectedTotalPrice() {
        selectedTotalPrice = cart.reduce(0) { total, product in
            let isSelected = selectedProducts[product.id] ?? false
            return total + (isSelected ? (Double(product.price) ?? 0) * Double(product.quantity) : 0)
        }
    }


    func selectProductsForCheckout(products: [CartProduct]) async {
        guard let url = URL(string: "\(baseURL)select/") else {
            print("Invalid URL: \(baseURL)select/")
            return
        }
        print("Request URL: \(url.absoluteString)")
        
        var token = await getToken()
        guard token != nil else { return }
        
        var request = createRequest(url: url, method: "POST", token: token!)
        
        do {
            let jsonData = try JSONEncoder().encode(products)
            request.httpBody = jsonData
            
            let (data, response) = try await URLSession.shared.data(for: request)
            handleCheckoutResponse(data: data, response: response)
        } catch {
            DispatchQueue.main.async {
                self.isError = true
            }
        }
    }
    
    // MARK: - Cart Management
    private func loadCart() {
        if let data = UserDefaults.standard.data(forKey: cartKey) {
            do {
                cart = try JSONDecoder().decode([Product].self, from: data)
            } catch {
                print("Error loading cart: \(error.localizedDescription)")
            }
        }
    }
    
    private func saveCart() {
        if let data = try? JSONEncoder().encode(cart) {
            UserDefaults.standard.set(data, forKey: cartKey)
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
    
    // MARK: - Product Selection Helpers
    func selectProduct(_ cartProduct: CartProduct) {
        selectedProducts[cartProduct.id] = true
    }

    func deselectProduct(_ cartProduct: CartProduct) {
        selectedProducts[cartProduct.id] = false
    }
    
    // MARK: - Token Management
    private func getToken() async -> String? {
        var token = authManager.accessToken
        if token == nil {
            print("Token not found, attempting to refresh...")
            await refreshAuthToken()
            token = authManager.accessToken
        }
        return token
    }
    
    // MARK: - Request Helper
    private func createRequest(url: URL, method: String, token: String) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
    
    // MARK: - Response Handling
    private func handleCheckoutResponse(data: Data, response: URLResponse) {
        if let httpResponse = response as? HTTPURLResponse {
            print("HTTP Status Code: \(httpResponse.statusCode)")
            if httpResponse.statusCode == 200 {
                print("Checkout successful")
            } else {
                print("Checkout failed")
                DispatchQueue.main.async {
                    self.isError = true
                }
            }
        }
    }
}
