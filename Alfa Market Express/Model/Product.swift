//
//  Product.swift
//  WareHouse1
//
//  Created by Said Tapaev on 06.07.2024.
//

import Foundation

struct Product: Identifiable, Decodable, Hashable, Encodable {
    var id: Int
    var name: String
    var description: String
    var price: String
    var imageUrl: String? 
    var category: Int
    var isFavorite: Bool
    var isInCart: Bool
    var quantity: Int

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case price
        case image // Это соответствует ключу в JSON
        case category
        case isFavorite
        case isInCart
        case quantity
    }
    
    

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
        price = try container.decode(String.self, forKey: .price)
        
        // Обработка значения `image` может быть `null`
        imageUrl = try container.decodeIfPresent(String.self, forKey: .image)
        
        category = try container.decode(Int.self, forKey: .category)
        isFavorite = try container.decodeIfPresent(Bool.self, forKey: .isFavorite) ?? false
        isInCart = try container.decodeIfPresent(Bool.self, forKey: .isInCart) ?? false
        quantity = try container.decodeIfPresent(Int.self, forKey: .quantity) ?? 1
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        try container.encode(price, forKey: .price)
        try container.encode(imageUrl, forKey: .image) // Кодирование опционального поля
        try container.encode(category, forKey: .category)
        try container.encode(isFavorite, forKey: .isFavorite)
        try container.encode(isInCart, forKey: .isInCart)
        try container.encode(quantity, forKey: .quantity)
    }
}
