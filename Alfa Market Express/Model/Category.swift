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
    let imageUrl: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case imageUrl = "image"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
        imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
    }
}
