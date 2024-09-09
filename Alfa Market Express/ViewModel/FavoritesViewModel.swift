//
//  FavoritesViewModel.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 09.09.2024.
//

import Foundation
import Combine

class FavoritesViewModel: ObservableObject {
    @Published var favorites: [Product] = [] {
        didSet {
            saveFavorites()
        }
    }
    
    private let favoritesKey = "cachedFavorites"
    private var cancellables = Set<AnyCancellable>()
    private let authManager = AuthManager.shared
    
    init() {
        loadFavorites()
    }
    
    func fetchFavorites() {
        guard let accessToken = authManager.accessToken else {
            print("Access token not available")
            return
        }
        
        let url = URL(string: "http://95.174.90.162:8000/api/favorites/")!
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
                    print("Failed to fetch favorites: \(error)")
                }
            }, receiveValue: { [weak self] products in
                self?.favorites = products
            })
            .store(in: &cancellables)
    }
    
    func toggleFavorite(_ product: Product) {
        guard let accessToken = authManager.accessToken else {
            print("Access token not available")
            return
        }
        
        let url = URL(string: "http://192.168.1.7:8000/api/favorites/add_remove/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Int] = ["product_id": product.id]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: [String: Int].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Failed to toggle favorite: \(error)")
                }
            }, receiveValue: { [weak self] response in
                if let productId = response["product_id"] {
                    if self?.isFavorite(product) == true {
                        self?.removeFromFavorites(product)
                    } else {
                        self?.addToFavorites(product)
                    }
                }
            })
            .store(in: &cancellables)
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
