//
//  Promotion.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 03.11.2024.
//

import Foundation

struct Promotion: Decodable {
    var id: Int
    var name: String
    var description: String
    var discountPercentage: String
    var isActive: Bool

    private enum CodingKeys: String, CodingKey {
        case id, name, description
        case discountPercentage = "discount_percentage"
        case isActive = "is_active"
    }
}

struct PromotionProduct: Identifiable, Decodable {
    var id: Int
    var name: String
    var description: String
    var price: String
    var image: String?
    var discountedPrice: Double
    var promotion: Promotion

    private enum CodingKeys: String, CodingKey {
        case id, name, description, price, image
        case discountedPrice = "discounted_price"
        case promotion
    }
}

struct PromotionData: Decodable {
    var name: String
    var promotionProducts: [PromotionProduct]
    var endTime: String

    private enum CodingKeys: String, CodingKey {
        case name
        case promotionProducts = "promotion_products"
        case endTime = "end_time"
    }
}
