//
//  CartProduct.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 14.09.2024.
//
struct CartProduct: Decodable , Encodable {
    let id: Int
    let product: Product
    let quantity: Int
    let getTotalPrice: Double
//    let selected: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, product, quantity
        case getTotalPrice = "get_total_price"
    }
}
