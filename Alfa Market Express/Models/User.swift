//
//  User.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 12.08.2024.
//
import Foundation


struct User: Codable {
    let id: Int64
    let accessToken: String
    let accessTokenExpire: Int64
    let refreshToken: String
    let refreshTokenExpire: Int64
}

struct AuthBody: Codable {
    let login: String
    let password: String
}

struct TokensInfo: Codable {
    let accessToken: String
    let accessTokenExpire: Int64
    let refreshToken: String
    let refreshTokenExpire: Int64
}

struct TokenInfo {
    let token: String
    let expiresAt: Int64
}

struct ErrorResponse: Codable {
    let code: Int
    let message: String
    
    func isAuth() -> Bool {
        return Errors.isAuthError(err: message)
    }
}

struct Developer: Codable {
    let id: Int64
    let name: String
    let department: String
}
