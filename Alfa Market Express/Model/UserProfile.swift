//
//  UserProfile.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 15.08.2024.
//
import Foundation



struct UserProfile: Codable {
    var username: String
    var firstName: String
    var lastName: String
    var storeName: String
    var storeAddress: String
    var storePhoneNumber: String
    var managerName: String
    var managerPhoneNumber: String
    var storeCode: String
    var outstandingDebt: Double
    var profileImageUrl: String
}
