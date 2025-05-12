//
//  CartProduct.swift
//  AlfaMarketExpress
//
//  Created by Said Tapaev on 24.12.2024.
//
import Foundation

struct CartProduct: Decodable, Encodable, Identifiable, Equatable {
    var id: Int
    var product: Product
    var quantity: Int
    var getTotalPrice: Double {
        (Double(product.price) ?? 0) * Double(quantity)
    }

    enum CodingKeys: String, CodingKey {
        case id, product, quantity
    }
}
