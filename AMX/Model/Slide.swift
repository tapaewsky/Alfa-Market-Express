//
//  Slide.swift
//  AlfaMarketExpress
//
//  Created by Said Tapaev on 24.12.2024.
//

import Foundation

struct Slide: Codable, Identifiable {
    let id: Int
    let title: String
    let image: String
    let link: String
    var description: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case image
        case link
        case description
    }
}

