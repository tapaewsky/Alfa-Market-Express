//
//  ProductResponse.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 28.11.2024.
//

import Foundation

struct ProductResponse: Decodable {
    var count: Int
    var next: String?
    var previous: String?
    var results: [Product]
}
