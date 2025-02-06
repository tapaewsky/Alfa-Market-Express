//
//  Slide.swift
//  AlfaMarketExpress
//
//  Created by Said Tapaev on 24.12.2024.
//

import Foundation

struct Slide: Codable, Identifiable {
    var id: Int
    var title: String
    var image: String
    var link: String?
    var description: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case image
        case link
        case description
    }
}

