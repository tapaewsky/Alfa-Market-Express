//
//  OrdersViewModel.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 25.09.2024.
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
    private let baseURL = "http://95.174.90.162:60/api/orders/"
    private let orderKey = "cashedOrder"
    init(cartViewModel: CartViewModel) {
        self.cartViewModel = cartViewModel
    }
    
    // MARK: - Fetch Orders
    func fetchOrders(completion: @escaping (Bool) -> Void) {
        print("Запрос продуктов из OrdersViewModel")
        
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
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }

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
                let fetchedOrders: [Order] = try JSONDecoder().decode([Order].self, from: data)
                print("Fetched orders: \(fetchedOrders)")
                DispatchQueue.main.async {
                    self.orders = fetchedOrders
                    // self.saveOrder() // Закомментировано для удаления кэширования
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

    
    // MARK: - Cancel Order
    func cancelOrder(orderId: Int) async {
        guard let url = URL(string: "\(baseURL)cancel/\(orderId)/") else { return }
        
        var token = await getToken()
        guard token != nil else { return }
        
        var request = createRequest(url: url, method: "PATCH", token: token!)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            let _ = try JSONDecoder().decode(CancelOrderResponse.self, from: data)
            DispatchQueue.main.async {
                self.errorMessage = "Order successfully canceled."
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Error canceling order: \(error.localizedDescription)"
            }
        }
    }
    
    // MARK: - Create Order
    func createOrder(items: [OrderItem], comments: String, accessToken: String) async throws -> Order {
        if items.isEmpty {
            throw URLError(.badServerResponse)
        }

        guard let url = URL(string: "\(baseURL)create/") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

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

    // MARK: - Convert CartProduct to OrderItem
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

    // MARK: - Update Order Comment
    func updateOrderComment(orderId: Int, comment: String) async {
        guard let url = URL(string: "\(baseURL)comment/\(orderId)/") else { return }
        
        var token = await getToken()
        guard token != nil else { return }
        
        var request = createRequest(url: url, method: "PATCH", token: token!)
        
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
    
    // MARK: - Helper Methods
    private func getToken() async -> String? {
        var token = authManager.accessToken
        if token == nil {
            print("Token not found, attempting to refresh...")
            await refreshAuthToken()
            token = authManager.accessToken
        }
        return token
    }
    
    private func createRequest(url: URL, method: String, token: String) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
    
    private func refreshAuthToken() async {
        await withCheckedContinuation { continuation in
            authManager.refreshAccessToken { success in
                continuation.resume(returning: success)
            }
        }
    }
    
    private func saveOrder() {
        if let data = try? JSONEncoder().encode(orders) {
            UserDefaults.standard.set(data, forKey: orderKey)
        }
    }
}
