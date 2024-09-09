//
//  CartViewModel.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 09.09.2024.
//

import Foundation
import Combine

class CartViewModel: ObservableObject {
    @Published var cart: [Product] = [] {
        didSet {
            saveCart()
            updateTotalPrice()
        }
    }
    @Published var totalPrice: Double = 0.0

    private let cartKey = "cachedCart"
    private var cancellables = Set<AnyCancellable>()

    init() {
        loadCart()
        updateTotalPrice()
    }

    func addToCart(_ product: Product) {
        if !cart.contains(where: { $0.id == product.id }) {
            cart.append(product)
        }
    }

    func removeFromCart(_ product: Product) {
        if let index = cart.firstIndex(where: { $0.id == product.id }) {
            cart.remove(at: index)
        }
    }

    func isInCart(_ product: Product) -> Bool {
        return cart.contains(where: { $0.id == product.id })
    }

    private func updateTotalPrice() {
        totalPrice = cart.reduce(0) { $0 + (Double($1.price) ?? 0.0) }
    }

    private func saveCart() {
        if let data = try? JSONEncoder().encode(cart) {
            UserDefaults.standard.set(data, forKey: cartKey)
        }
    }

    private func loadCart() {
        if let data = UserDefaults.standard.data(forKey: cartKey),
           let savedCart = try? JSONDecoder().decode([Product].self, from: data) {
            cart = savedCart
        }
    }
}
