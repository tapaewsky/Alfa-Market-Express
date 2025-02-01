//
//  Category.swift
//  AlfaMarketExpress
//
//  Created by Said Tapaev on 24.12.2024.
//

import Foundation

struct Category: Identifiable, Decodable, Encodable, Equatable {
    let id: Int
    let name: String
    let description: String
    let imageUrl: String?

    enum CodingKeys: String, CodingKey {
        case id, name, description, imageUrl = "image"
    }
}
