//
//  Category 2.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 25.09.2024.
//


import Foundation

struct Category: Identifiable, Decodable, Encodable {
    let id: Int
    let name: String
    let description: String
    let imageUrl: String?

    enum CodingKeys: String, CodingKey {
        case id, name, description, imageUrl = "image"
    }
}