//
//  FavoritesVM.swift
//  AlfaMarketExpress
//
//  Created by Said Tapaev on 24.12.2024.
//

import Combine
import Foundation

class FavoritesViewModel: ObservableObject {
    @Published var favorites: [Product] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let authManager = AuthManager.shared
//    private let baseUrl = "https://alfamarketexpress.ru/api"
    var baseURL: String = BaseURL.alfa

    func fetchFavorites(completion: @escaping (Bool) -> Void) {
        guard let accessToken = authManager.accessToken else {
            print("Access token не найден.")
            completion(false)
            return
        }

        guard let url = URL(string: "\(baseURL)favorites/") else {
            print("Неверный URL")
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        print("Запрос на сервер: \(url.absoluteString)")

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error {
                print("Ошибка при получении избранного: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }

            guard let data else {
                print("Нет данных в ответе")
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }

            do {
                let favorites = try JSONDecoder().decode([Product].self, from: data)

                DispatchQueue.main.async {
                    self.favorites = favorites

                    completion(true)
                }
            } catch {
                print("Ошибка декодирования избранного: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(false)
                }
            }

        }.resume()
    }

    func toggleFavorite(for product: Product) async {
        guard let accessToken = authManager.accessToken else {
            errorMessage = "Access token not found."
            return
        }

        isLoading = true
        defer { isLoading = false }

        guard let url = URL(string: "\(baseURL)favorites/add_remove/") else {
            errorMessage = "Неверный URL"
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody: [String: Any] = ["product_id": product.id]
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)

        print("Запрос на сервер: \(url.absoluteString)")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    DispatchQueue.main.async {
                        self.toggleProductFavoriteStatus(product: product)
                    }
                } else {
                    errorMessage = "Failed to update favorite. Response code: \(httpResponse.statusCode)"
                }
            }
        } catch {
            errorMessage = "Ошибка при обновлении избранного: \(error.localizedDescription)"
        }
    }

    private func toggleProductFavoriteStatus(product: Product) {
        if let index = favorites.firstIndex(where: { $0.id == product.id }) {
            favorites.remove(at: index)
        } else {
            favorites.append(product)
        }
    }

    func isFavorite(_ product: Product) -> Bool {
        favorites.contains(where: { $0.id == product.id })
    }
}
