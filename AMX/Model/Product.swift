//
//  Product.swift
//  AlfaMarketExpress
//
//  Created by Said Tapaev on 24.12.2024.
//

import Foundation

struct Product: Identifiable, Decodable, Hashable, Encodable, Equatable {
    var id: Int
    var name: String
    var description: String
    var price: String
    var imageUrl: String?
    var images: [ProductImage] // Массив объектов ProductImage
    var category: Int
    var isFavorite: Bool
    var quantity: Int

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case price
        case imageUrl = "main_image"
        case images
        case category
        case isFavorite
        case quantity
    }

    // Инициализатор для декодирования
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
        price = try container.decode(String.self, forKey: .price)
        imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
        images = try container.decodeIfPresent([ProductImage].self, forKey: .images) ?? [] // Декодируем как массив объектов
        category = try container.decodeIfPresent(Int.self, forKey: .category) ?? 0
        isFavorite = try container.decodeIfPresent(Bool.self, forKey: .isFavorite) ?? false
        quantity = try container.decodeIfPresent(Int.self, forKey: .quantity) ?? 1
    }

    // Функция для кодирования
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        try container.encode(price, forKey: .price)
        try container.encode(imageUrl, forKey: .imageUrl)
        try container.encode(images, forKey: .images) // Кодируем массив объектов ProductImage
        try container.encode(category, forKey: .category)
        try container.encode(isFavorite, forKey: .isFavorite)
        try container.encode(quantity, forKey: .quantity)
    }
}

// Структура для каждого изображения (добавлен протокол Encodable)
struct ProductImage: Decodable, Hashable, Equatable, Encodable { // Теперь соответствует Encodable
    var id: Int
    var image: String // URL изображения
}
