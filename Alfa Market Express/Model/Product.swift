//
//  Product.swift
//  WareHouse1
//
//  Created by Said Tapaev on 06.07.2024.
//
import Foundation
// fgdsgfdgfdgdfgdfdfgdgfdgd
struct Product: Identifiable, Decodable, Encodable {
    let id: Int
    let name: String
    let description: String
    let price: String
    let imageUrl: String
    let category: Int
    var isFavorite: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case price
        case imageUrl = "image"
        case category
    }
}

