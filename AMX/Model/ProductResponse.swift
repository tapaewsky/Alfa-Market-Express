//
//  ProductResponse.swift
//  AlfaMarketExpress
//
//  Created by Said Tapaev on 24.12.2024.
//

import Foundation

struct ProductResponse: Decodable {
    var count: Int
    var next: String?
    var previous: String?
    var results: [Product]
}

