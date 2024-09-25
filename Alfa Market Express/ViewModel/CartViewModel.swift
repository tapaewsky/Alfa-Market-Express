//
//  CartViewModel.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 09.09.2024.
//
import Foundation
import Combine

class CartViewModel: ObservableObject {
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
    
    var dataId: Int = 0
    private let cartKey = "cachedCart"
    private let baseURL = "http://95.174.90.162:60/api/cart/"
    
    private var authManager = AuthManager.shared

    init(favoritesViewModel: FavoritesViewModel) {
        self.favoritesViewModel = favoritesViewModel
        loadCart()
    }

    func fetchCart(completion: @escaping (Bool) -> Void) {
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

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Ошибка при получении корзины: \(error.localizedDescription)")
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
                let cartProducts = try JSONDecoder().decode([CartProduct].self, from: data)
                DispatchQueue.main.async {
                    self.cartProduct = cartProducts
                    self.saveCart()
                    completion(true)
                }
            } catch {
                print("Ошибка при декодировании корзины: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }.resume()
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
        print(dataId)
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
    
    func clearSelection() {
        for product in cart {
            selectedProducts[product.id] = false // Сбрасываем все выборы
        }
    }
    
    var selectedTotalPriceу: Double {
        cartProduct.reduce(0) { total, product in
            let isSelected = selectedProducts[product.id] ?? false
            return total + (isSelected ? product.getTotalPrice : 0)
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
            if selectedProducts[product.id] == true {
                return total + (Double(product.price) ?? 0) * Double(product.quantity)
            }
            return total
        }
    }
    func selectProductsForCheckout(products: [CartProduct]) async {
        // Проверка URL
        guard let url = URL(string: "\(baseURL)select/") else {
            print("Неверный URL: \(baseURL)select/")
            return
        }
        print("URL запроса: \(url.absoluteString)")

        var token = authManager.accessToken
        if token == nil {
            print("Токен не найден, пытаемся обновить...")
            await refreshAuthToken()
            token = authManager.accessToken
            if token == nil {
                print("Токен не удалось обновить. Прерывание запроса.")
                return
            }
        }
        
        // Логируем полученный токен
        print("Токен для авторизации: \(token!)")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Логируем метод запроса
        print("HTTP метод запроса: \(request.httpMethod ?? "Не указан")")

        // Добавляем заголовки
        request.setValue("Bearer \(token!)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Логируем заголовки запроса
        print("Заголовки запроса: \(request.allHTTPHeaderFields ?? [:])")
        
        // Формируем тело запроса
        let body: [String: Any] = ["selected_items":  dataId] 
        
        // Логируем тело запроса
        if let httpBody = try? JSONSerialization.data(withJSONObject: body) {
            print("Тело запроса: \(String(data: httpBody, encoding: .utf8) ?? "Не удалось закодировать тело запроса")")
            request.httpBody = httpBody
        } else {
            print("Ошибка формирования тела запроса.")
            return
        }

        do {
            // Отправляем запрос
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Логируем ответ сервера
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP статус код: \(httpResponse.statusCode)")
            } else {
                print("Не удалось получить HTTP ответ.")
            }
            
            // Логируем полученные данные
            if let responseData = String(data: data, encoding: .utf8) {
                print("Ответ от сервера: \(responseData)")
            } else {
                print("Не удалось декодировать ответ от сервера.")
            }

            // Попытка декодирования JSON
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                if let message = json["message"] as? String {
                    print("Сообщение от сервера: \(message)")
                } else {
                    print("Не удалось найти ключ 'message' в ответе.")
                }
            } else {
                print("Не удалось преобразовать ответ в JSON.")
            }
            
        } catch {
            // Логируем ошибки запроса
            print("Ошибка при выполнении запроса: \(error.localizedDescription)")
        }
    }
    
//    func selectProductsForCheckout(product: Product, selectedProductIds: [Int], completion: @escaping (Bool) -> Void) {
//        guard let url = URL(string: "\(baseURL)select/") else {
//            print("Неверный URL")
//            completion(false)
//            return
//        }
//
//        guard let accessToken = authManager.accessToken else {
//            print("Access token not found.")
//            completion(false)
//            return
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        // Создаем тело запроса с выбранными продуктами
//        let body: [String: Any] = ["selected_items": selectedProductIds]
//        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
//
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                print("Ошибка при выборе продуктов: \(error.localizedDescription)")
//                DispatchQueue.main.async {
//                    completion(false)
//                }
//                return
//            }
//
//            guard let data = data else {
//                print("Нет данных в ответе")
//                DispatchQueue.main.async {
//                    completion(false)
//                }
//                return
//            }
//
//            do {
//                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
//                   let message = json["message"] as? String {
//                    print("Ответ от сервера: \(message)")
//                    DispatchQueue.main.async {
//                        completion(true)
//                    }
//                } else {
//                    print("Не удалось декодировать ответ")
//                    DispatchQueue.main.async {
//                        completion(false)
//                    }
//                }
//            } catch {
//                print("Ошибка при декодировании ответа: \(error.localizedDescription)")
//                DispatchQueue.main.async {
//                    completion(false)
//                }
//            }
//        }.resume()
//    }

    private func loadCart() {
        if let data = UserDefaults.standard.data(forKey: cartKey) {
            do {
                cart = try JSONDecoder().decode([Product].self, from: data)
            } catch {
                print("Ошибка при загрузке корзины: \(error.localizedDescription)")
            }
        }
    }
    
    private func saveCart() {
        if let data = try? JSONEncoder().encode(cart) {
            UserDefaults.standard.set(data, forKey: cartKey)
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
