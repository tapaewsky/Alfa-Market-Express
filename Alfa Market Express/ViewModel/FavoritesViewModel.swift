//
//  FavoritesViewModel.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 09.09.2024.
//
import Foundation
import Combine

class FavoritesViewModel: ObservableObject {
    @Published var favorites: [Product] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let favoritesKey = "cachedFavorites"
    private let authManager = AuthManager.shared
    private let networkMonitor = NetworkMonitor()
    private let baseUrl = "http://95.174.90.162:60/api"

    init() {
        loadFavorites()
//        await fetchFavorites()
    }

    private func loadFavorites() {
        if let data = UserDefaults.standard.data(forKey: favoritesKey),
           let savedFavorites = try? JSONDecoder().decode([Product].self, from: data) {
            self.favorites = savedFavorites
        }
    }

    func fetchFavorites() async {
        guard let accessToken = authManager.accessToken else {
            errorMessage = "Access token not found."
            return
        }

        guard let url = URL(string: "\(baseUrl)/favorites/") else {
            print("Неверный URL")
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                let favorites = try JSONDecoder().decode([Product].self, from: data)
                DispatchQueue.main.async {
                    self.favorites = favorites // Обновление локального массива
                    self.saveFavorites()
                }
            } else {
                errorMessage = "Ошибка при получении избранного"
            }
        } catch {
            errorMessage = "Ошибка при получении избранного: \(error.localizedDescription)"
        }
    }


    func toggleFavorite(for product: Product) async {
        guard let accessToken = authManager.accessToken else {
            errorMessage = "Access token not found."
            return
        }

        isLoading = true
        defer { isLoading = false }

        guard let url = URL(string: "\(baseUrl)/favorites/add_remove/") else {
            errorMessage = "Неверный URL"
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody: [String: Any] = ["product_id": product.id]
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    // Обновляем локальные данные
                    DispatchQueue.main.async {
                        self.toggleProductFavoriteStatus(product: product)
                        self.saveFavorites()
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
        print("Товар \(product.name) теперь \(isFavorite(product) ? "в избранном" : "не в избранном")")
    }

    private func saveFavorites() {
        if let data = try? JSONEncoder().encode(favorites) {
            UserDefaults.standard.set(data, forKey: favoritesKey)
        }
    }

    func isFavorite(_ product: Product) -> Bool {
        return favorites.contains(where: { $0.id == product.id })
    }
}
