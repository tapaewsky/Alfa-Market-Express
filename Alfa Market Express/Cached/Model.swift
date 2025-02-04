//
//  Model.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 23.11.2024.
//

import SwiftData

@Model
class CachedProduct: Identifiable {
    @Attribute(.unique) var id: Int
    var name: String
    var productDescription: String
    var price: String
    var discountedPrice: Double?
    var imageUrl: String?
    var category: Int
    var isFavorite: Bool
    var quantity: Int
    
    init(id: Int, name: String, description: String, price: String, discountedPrice: Double?, imageUrl: String?, category: Int, isFavorite: Bool, quantity: Int) {
        self.id = id
        self.name = name
        self.productDescription = description
        self.price = price
        self.discountedPrice = discountedPrice
        self.imageUrl = imageUrl
        self.category = category
        self.isFavorite = isFavorite
        self.quantity = quantity
    }
}
