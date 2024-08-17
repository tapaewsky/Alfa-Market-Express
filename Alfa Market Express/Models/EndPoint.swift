//
//   Endpoint.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 12.08.2024.
//

import Foundation


import Foundation

enum Endpoint {
    static let baseURL: String = "https://lev.customapp.tech/"

    case register
    case login
    case refreshTokens
    case getDevelopers

    func path() -> String {
        switch self {
        case .register: return "api/register"
        case .login: return "api/login"
        case .refreshTokens: return "api/refresh_tokens"
        case .getDevelopers: return "api/get_devs"
        }
    }

    var absoluteURL: URL {
        URL(string: Endpoint.baseURL + self.path())!
    }
}
