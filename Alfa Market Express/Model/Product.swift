//
//  Product.swift
//  WareHouse1
//
//  Created by Said Tapaev on 06.07.2024.
//

import Foundation

struct Product: Identifiable, Decodable, Encodable, Hashable {
    let id: Int
    let name: String
    let description: String
    let price: Double
    let imageUrl: String
    let category: Int
    var isFavorite: Bool = false
    var isInCart: Bool = false
    var quantity: Int = 0
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case price
        case imageUrl = "image"
        case category
    }
    
    // Custom decoding for price
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
        imageUrl = try container.decode(String.self, forKey: .imageUrl)
        category = try container.decode(Int.self, forKey: .category)
        
        // Decode price as string and convert to Double
        let priceString = try container.decode(String.self, forKey: .price)
        if let priceValue = Double(priceString) {
            price = priceValue
        } else {
            throw DecodingError.dataCorruptedError(forKey: .price, in: container, debugDescription: "Price string could not be converted to Double")
        }
    }
}
