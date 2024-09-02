//
//  Category.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 09.08.2024.
//

import Foundation


struct Category: Identifiable, Decodable, Encodable {
    let id: Int
    let name: String
    let description: String
    let imageUrl: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case imageUrl = "image"
    }
}
