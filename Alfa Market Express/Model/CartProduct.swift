//
//  CartProduct.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 14.09.2024.
//
struct CartProduct: Codable {
    let id: Int
    let product: Product
    let quantity: Int
    let getTotalPrice: Double

    init(id: Int, product: Product, quantity: Int, getTotalPrice: Double) {
        self.id = id
        self.product = product
        self.quantity = quantity
        self.getTotalPrice = getTotalPrice
    }
}
