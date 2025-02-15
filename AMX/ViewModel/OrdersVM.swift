//
//  OrdersVM.swift
//  AlfaMarketExpress
//
//  Created by Said Tapaev on 24.12.2024.
//

import Foundation
import Combine

class OrdersViewModel: ObservableObject {
    @Published var orders: [Order] = []
    @Published var errorMessage: String?
    @Published var cartViewModel: CartViewModel
    @Published var isLoading = false
    @Published var isError = false
    private var cancellables = Set<AnyCancellable>()
    var authManager = AuthManager.shared
//    private let baseURL = "https://alfamarketexpress.ru/api/orders/"
    
    var baseURL: String = BaseURL.alfa + "orders/"
    
  
    init(cartViewModel: CartViewModel) {
        self.cartViewModel = cartViewModel
    }
    
    func fetchOrders(completion: @escaping (Bool) -> Void) {
        guard let accessToken = authManager.accessToken else {
            print("Access token not found.")
            completion(false)
            return
        }
        
        guard let url = URL(string: baseURL) else {
            print("Неверный URL")
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        print("Запрос на сервер: \(url.absoluteString)")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Ошибка при получении заказов: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }
            
            guard let data = data else {
                print("Нет данных в ответе")
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }
            
            do {
                let fetchedOrders = try JSONDecoder().decode([Order].self, from: data)
                DispatchQueue.main.async {
                    self.orders = fetchedOrders
                    completion(true)
                }
            } catch {
                print("Ошибка декодирования заказов: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }.resume()
    }
    
    func cancelOrder(orderId: Int) async {
        guard let url = URL(string: "\(baseURL)cancel/\(orderId)/") else {
            print("Invalid URL")
            return
        }
        
        var token = await authManager.getToken()
        guard token != nil else {
            print("Failed to retrieve token")
            return
        }
        
        var request = createRequest(url: url, method: "PATCH", token: token!)
        print("Sending request to: \(url)")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                print("Response status code: \(httpResponse.statusCode)")
            }
            
            let decodedResponse = try JSONDecoder().decode(CancelOrderResponse.self, from: data)
            print("Successfully decoded response: \(decodedResponse)")
            
            DispatchQueue.main.async {
                self.errorMessage = "Order successfully canceled."
            }
        } catch {
            print("Error during request: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.errorMessage = "Error canceling order: \(error.localizedDescription)"
            }
        }
    }
    
    func createOrder(items: [OrderItem], comments: String, accessToken: String) async throws -> Order {
        if items.isEmpty {
            throw URLError(.badServerResponse)
        }

        guard let url = URL(string: "\(baseURL)create/") else {
            throw URLError(.badURL)
        }
        var token = await authManager.getToken()
        
        var request = createRequest(url: url, method: "POST", token: token!)
        
        print("Запрос на сервер: \(url.absoluteString)")

        let orderRequest = CreateOrderRequest(items: items, comments: comments)

        do {
            let data = try JSONEncoder().encode(orderRequest)
            request.httpBody = data

            let (dataResponse, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 201 {
                throw URLError(.badServerResponse)
            }

            let responseOrder = try JSONDecoder().decode(Order.self, from: dataResponse)
            return responseOrder
        } catch {
            throw error
        }
    }

    func orderItemFromCartProduct(_ cartProduct: CartProduct) -> OrderItem {
        let orderItem = OrderItem(
            product: cartProduct.product.name,
            productId: cartProduct.product.id,
            quantity: cartProduct.quantity,
            price: Double(cartProduct.product.price) ?? 0.0,
            image: cartProduct.product.imageUrl ?? "defaultImageUrl"
        )
        return orderItem
    }

    func updateOrderComment(orderId: Int, comment: String) async {
        guard let url = URL(string: "\(baseURL)comment/\(orderId)/") else { return }
        
        var token = await authManager.getToken()
        guard token != nil else { return }
        
        var request = createRequest(url: url, method: "PATCH", token: token!)
        
        print("Запрос на сервер: \(url.absoluteString)")
        
        let commentData = UpdateCommentRequest(comments: comment)
        
        do {
            request.httpBody = try JSONEncoder().encode(commentData)
            let (data, response) = try await URLSession.shared.data(for: request)
            let _ = try JSONDecoder().decode(UpdateCommentResponse.self, from: data)
            DispatchQueue.main.async {
                self.errorMessage = "Comment updated."
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Error updating comment: \(error.localizedDescription)"
            }
        }
    }

    private func createRequest(url: URL, method: String, token: String) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
}
