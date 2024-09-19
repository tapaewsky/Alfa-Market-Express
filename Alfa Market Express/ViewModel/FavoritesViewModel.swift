//
//  FavoritesViewModel.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 09.09.2024.
//

import Foundation
import Combine

class FavoritesViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    @Published var favorites: [Product] = [] {
        didSet {
            saveFavorites()
        }
    }
    
    private let favoritesKey = "cachedFavorites"
    private var cancellables = Set<AnyCancellable>()
    private let authManager = AuthManager.shared
    private let networkMonitor = NetworkMonitor()
    
    init() {
       
        loadFavorites()
    }
    
    func fetchFavorites() {
        guard networkMonitor.isConnected else {
            print("No internet connection")
            return
        }
        
        guard let accessToken = authManager.accessToken else {
            print("Access token not available")
            return
        }
        
        let url = URL(string: "http://95.174.90.162:60/api/favorites/")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: [Product].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Failed to fetch favorites: \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] products in
                self?.favorites = products
            })
            .store(in: &cancellables)
    }
    
    func toggleFavorite(for product: Product) async {
        guard let accessToken = authManager.accessToken else {
            errorMessage = "Access token not found."
            return
        }

        isLoading = true
        defer { isLoading = false }

        guard let url = URL(string: "http://95.174.90.162:60/api/favorites/add_remove/") else {
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
                print("Код статуса HTTP: \(httpResponse.statusCode)")
                if httpResponse.statusCode == 200 {
                    toggleProductFavoriteStatus(product: product)
                } else {
                    errorMessage = "Failed to update favorite. Response code: \(httpResponse.statusCode)"
                    if let errorBody = String(data: data, encoding: .utf8) {
                        errorMessage = "Error body: \(errorBody)"
                    }
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

    func someFunctionThatCallsToggleFavorite(product: Product) {
        Task {
            await toggleFavorite(for: product)
        }
    }
    
    func addToFavorites(_ product: Product) {
        if !favorites.contains(where: { $0.id == product.id }) {
            favorites.append(product)
        }
    }
    
    func removeFromFavorites(_ product: Product) {
        if let index = favorites.firstIndex(where: { $0.id == product.id }) {
            favorites.remove(at: index)
        }
    }
    
    func isFavorite(_ product: Product) -> Bool {
        return favorites.contains(where: { $0.id == product.id })
    }
    
    private func saveFavorites() {
        if let data = try? JSONEncoder().encode(favorites) {
            UserDefaults.standard.set(data, forKey: favoritesKey)
        }
    }
    
    private func loadFavorites() {
        if let data = UserDefaults.standard.data(forKey: favoritesKey),
           let savedFavorites = try? JSONDecoder().decode([Product].self, from: data) {
            favorites = savedFavorites
        }
    }
}
