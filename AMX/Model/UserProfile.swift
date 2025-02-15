//
//  UserProfile.swift
//  AlfaMarketExpress
//
//  Created by Said Tapaev on 24.12.2024.
//

import Foundation

struct UserProfile: Codable {
    var id: Int
    var username: String
    var firstName: String
    var lastName: String
    var storeName: String
    var storeImageUrl: String?
    var storeAddress: String
    var storePhoneNumber: String
    var storeCode: String
    var managerName: String
    var managerPhoneNumber: String
    var remainingDebt: String
    var favoriteProducts: [Int]

    enum CodingKeys: String, CodingKey {
        case id
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case storeName = "store_name"
        case storeImageUrl = "store_image"
        case storeAddress = "store_address"
        case storePhoneNumber = "store_phone"
        case storeCode = "store_code"
        case remainingDebt = "remaining_debt"
        case favoriteProducts = "favorite_products"
        case managerName = "manager_name"
        case managerPhoneNumber = "manager_phone"
    }
}
