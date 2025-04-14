//
//  Order.swift
//  AlfaMarketExpress
//
//  Created by Said Tapaev on 24.12.2024.
//

import Foundation

struct Order: Codable {
    let id: Int
    let items: [OrderItem]
    let comments: String
    let status: String
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id, items, comments, status
        case createdAt = "created_at"
    }
}

struct OrderItem: Codable {
    let product: String
    let productId: Int
    let quantity: Int
    let price: Double
    let image: String?

    enum CodingKeys: String, CodingKey {
        case product
        case productId = "product_id"
        case quantity, price, image
    }
}

struct CreateOrderRequest: Codable {
    let items: [OrderItem]
    let comments: String
}

struct CancelOrderResponse: Codable {
    let status: String
}

struct UpdateCommentRequest: Codable {
    let comments: String
}

struct UpdateCommentResponse: Codable {
    let status: String
    let comments: String
}
