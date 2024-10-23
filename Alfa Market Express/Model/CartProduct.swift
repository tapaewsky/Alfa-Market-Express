//
//  CartProduct.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 14.09.2024.
//
import Foundation

struct CartProduct: Decodable, Encodable, Identifiable {
    var id: Int
    var product: Product
    var quantity: Int
    var getTotalPrice: Double
    

    enum CodingKeys: String, CodingKey {
        case id, product, quantity, getTotalPrice = "get_total_price"
    }
}
