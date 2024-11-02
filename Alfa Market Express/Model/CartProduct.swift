//
//  CartProduct.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 14.09.2024.
//
import Foundation

struct CartProduct: Decodable, Encodable, Identifiable, Equatable {
    var id: Int
    var product: Product
    var quantity: Int

    var getTotalPrice: Double {
        return (Double(product.price) ?? 0) * Double(quantity) 
    }

    enum CodingKeys: String, CodingKey {
        case id, product, quantity
    }
}
