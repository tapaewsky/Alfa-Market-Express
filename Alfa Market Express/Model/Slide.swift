//
//  Slide.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 16.10.2024.
//

struct Slide: Codable, Identifiable {
    let id: Int
    let title: String
    let image: String
    let link: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case image
        case link
    }
}
