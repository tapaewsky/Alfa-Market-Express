//
//  Product.swift
//  AlfaMarketExpress
//
//  Created by Said Tapaev on 24.12.2024.
//

import Foundation

struct Product: Identifiable, Decodable, Hashable, Encodable {
    var id: Int
    var name: String
    var description: String
    var price: String
    var discountedPrice: Double?
    var imageUrl: String?
    var category: Int
    var isFavorite: Bool
    var quantity: Int

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case price
        case discountedPrice = "discounted_price"
        case imageUrl = "image"
        case category
        case isFavorite
        case quantity
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
        price = try container.decode(String.self, forKey: .price)
        discountedPrice = try container.decodeIfPresent(Double.self, forKey: .discountedPrice)
        imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
        category = try container.decodeIfPresent(Int.self, forKey: .category) ?? 0
        isFavorite = try container.decodeIfPresent(Bool.self, forKey: .isFavorite) ?? false
        quantity = try container.decodeIfPresent(Int.self, forKey: .quantity) ?? 1
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        try container.encode(price, forKey: .price)
        try container.encode(discountedPrice, forKey: .discountedPrice)
        try container.encode(imageUrl, forKey: .imageUrl)
        try container.encode(category, forKey: .category)
        try container.encode(isFavorite, forKey: .isFavorite)
        try container.encode(quantity, forKey: .quantity)
    }
}
