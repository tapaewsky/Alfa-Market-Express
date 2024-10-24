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
    @Published var cartProduct: [CartProduct] = []
    @Published var cart: [Product] = []
    
    @Published var totalPrice: Double = 0.0
    @Published var selectedTotalPrice: Double = 0.0
    @Published var isLoading = false
    @Published var isError = false
    @Published var selectedProducts: [Int: Bool] = [:]
    @Published var selectedProduct: Product?
    @Published var dataId: Int = 0
    private let baseURL = "http://95.174.90.162:60/api/cart/"
    private var authManager = AuthManager.shared

    init() {
           for product in cartProduct {
               selectedProducts[product.id] = false // Или true, если хотите, чтобы по умолчанию некоторые товары были выбраны
           }
       }
    
    // MARK: - API Calls
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
    

    func updateProductQuantity(productId: Int, newQuantity: Int) async {
        guard let url = URL(string: "\(baseURL)update/\(productId)/") else {
            print("Некорректный URL")
            return
        }

        let token = await getToken()
        guard token != nil else {
            print("Токен равен nil")
            return
        }

        var request = createRequest(url: url, method: "PATCH", token: token!)
        let body: [String: Any] = ["quantity": newQuantity]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        print("Отправка запроса на обновление продукта \(productId) с новой величиной \(newQuantity)")
        print("URL: \(url)")
        print("Тело запроса: \(String(data: request.httpBody!, encoding: .utf8) ?? "")")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Получен HTTP-ответ: \(httpResponse.statusCode)")
                
                print("Полученные данные: \(String(data: data, encoding: .utf8) ?? "Нет данных")")
                
                if httpResponse.statusCode == 200 {
                    do {
                        let updatedProduct = try JSONDecoder().decode(CartProduct.self, from: data)
                    } catch {
                        print("Ошибка декодирования: \(error.localizedDescription)")
                    }
                } else {
                    print("Ошибка при обновлении продукта: \(httpResponse.statusCode)")
                }
            }
        } catch {
            print("Произошла ошибка: \(error.localizedDescription)")
        }
    }
    
    // This function is used to delete a product from the cart
    func removeFromCard(_ product: Product) async {
        print("Attempting to remove product: \(product.name), ID: \(product.id)")

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
                print("Cart updated: product with ID \(product.id) removed")
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
                self.cart.removeAll { $0.id == productId }
                print("Cart updated: product with ID \(productId) removed")
            }
        } catch {
            print("Error removing product from cart: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.isError = true
            }
        }
    }

    func calculateTotalPrice() -> Double {
        var total: Double = 0.0
        for cartItem in cartProduct {
            if let isSelected = selectedProducts[cartItem.product.id], isSelected {
                if let price = Double(cartItem.product.price) {
                    total += price * Double(cartItem.quantity)
                }
            }
        }
        return total
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
        
       
        print("Товар \(product.name) \(isSelected ? "снят с выбора" : "выбран")")
        print("Текущее состояние selectedProducts: \(selectedProducts)")
        
        updateSelectedTotalPrice()
    }


    func updateSelectedTotalPrice() {
        print("cartProduct: \(cartProduct)")
        let selectedProductsList = cartProduct.filter { selectedProducts[$0.id] ?? false }

      

        print("Выбранные продукты для расчета цены: \(selectedProductsList)")

        selectedTotalPrice = selectedProductsList.reduce(0) { total, product in
            let price = Double(product.product.price) ?? 0
            let quantity = product.quantity
            print("Продукт: \(product.product.name), Цена: \(price), Количество: \(quantity)")
            return total + (price * Double(quantity))
        }

        print("Общая цена выбранных продуктов: \(selectedTotalPrice)")
    }

    func selectProductsForCheckout(products: [CartProduct]) async {
        guard let url = URL(string: "\(baseURL)select/") else {
            print("Invalid URL: \(baseURL)select/")
            return
        }
        
        print("Request URL: \(url.absoluteString)")
        
        var token = await getToken()
        guard token != nil else {
            print("Token not found, aborting checkout.")
            return
        }
        
        var request = createRequest(url: url, method: "POST", token: token!)

      
        print("Selected products for checkout:")
        for product in products {
            print("Product ID: \(product.product.id), Name: \(product.product.name), Quantity: \(product.quantity)")
        }
        
        do {
            let jsonData = try JSONEncoder().encode(products)
            request.httpBody = jsonData
            
            print("Sending request with body: \(String(data: jsonData, encoding: .utf8) ?? "Invalid JSON")") // Печатаем JSON-тело запроса
            
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
    
    // MARK: - Cart Management
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
        return authManager.accessToken
    }

    private func createRequest(url: URL, method: String, token: String) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
    
    // MARK: - Handle Response
    private func handleCheckoutResponse(data: Data, response: URLResponse) {
        if let httpResponse = response as? HTTPURLResponse {
            print("HTTP Status Code: \(httpResponse.statusCode)")
        }
        
        if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            print("Checkout Response: \(jsonResponse)")
        } else {
            print("Failed to decode response data")
        }
    }
    func updateTotalPrice()  {
        totalPrice = cartProduct.reduce(0) { total, cartProduct in
            return total + cartProduct.getTotalPrice
        }
    }
}
