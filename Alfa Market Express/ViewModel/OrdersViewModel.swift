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
    private var cancellables = Set<AnyCancellable>()
    private var authManager = AuthManager.shared
    private let baseURL = "http://95.174.90.162:60/api/orders/"
    
    init(cartViewModel: CartViewModel) {
        self.cartViewModel = cartViewModel
    }
    
    // Получить заказы
    func fetchOrders(completion: @escaping (Bool) -> Void) {
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
                print("Error fetching orders: \(error.localizedDescription)")
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
                let fetchedOrders = try JSONDecoder().decode([Order].self, from: data)
                DispatchQueue.main.async {
                    self.orders = fetchedOrders
                    completion(true)
                }
            } catch {
                print("Error decoding orders: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }.resume()
    }
    
    // Отменить заказ
    func cancelOrder(orderId: Int) async {
        guard let url = URL(string: "\(baseURL)cancel/\(orderId)/") else { return }
        
        var token = await getToken()
        guard token != nil else { return }
        
        var request = createRequest(url: url, method: "PATCH", token: token!)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            let _ = try JSONDecoder().decode(CancelOrderResponse.self, from: data)
            DispatchQueue.main.async {
                self.errorMessage = "Заказ успешно отменен."
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Ошибка при отмене заказа: \(error.localizedDescription)"
            }
        }
    }
    
    func createOrder(items: [OrderItem], comments: String, accessToken: String) async throws -> Order {
        // Логируем товары в корзине перед созданием заказа
        print("Товары в корзине перед созданием заказа: \(cartViewModel.cartProduct)")

        let products = cartViewModel.cartProduct.map { orderItemFromCartProduct($0) }
        
        // Логируем количество товаров после конвертации
        print("Конвертированные товары для заказа: \(products)")
        
        if products.isEmpty {
            print("Ошибка: корзина пуста, невозможно создать заказ.")
            throw URLError(.badServerResponse)
        }
        
        guard let url = URL(string: "\(baseURL)create/") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let orderRequest = CreateOrderRequest(items: products, comments: comments)

        do {
            let data = try JSONEncoder().encode(orderRequest)
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Отправляемые данные: \(jsonString)")
            }
            request.httpBody = data

            let (dataResponse, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse {
                print("Response code: \(httpResponse.statusCode)")
                if httpResponse.statusCode != 201 {
                    let responseString = String(data: dataResponse, encoding: .utf8)
                    print("Ответ сервера: \(responseString ?? "No response")")
                    throw URLError(.badServerResponse)
                }
            }

            let responseOrder = try JSONDecoder().decode(Order.self, from: dataResponse)
            return responseOrder
        } catch {
            print("Ошибка при создании заказа: \(error.localizedDescription)")
            throw error
        }
    }

    // Логируем каждый OrderItem, создаваемый из CartProduct
    private func orderItemFromCartProduct(_ cartProduct: CartProduct) -> OrderItem {
        print("Создание OrderItem для продукта: \(cartProduct)")
        let orderItem = OrderItem(
            product: cartProduct.product.name,
            productId: cartProduct.product.id,
            quantity: cartProduct.quantity,
            price: cartProduct.product.price,
            image: cartProduct.product.imageUrl ?? "defaultImageUrl"
        )
        print("Создан OrderItem: \(orderItem)")
        return orderItem
    }

    // Обновить комментарий заказа
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
                self.errorMessage = "Комментарий обновлен."
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Ошибка при обновлении комментария: \(error.localizedDescription)"
            }
        }
    }
    
    // Вспомогательные методы
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
}
