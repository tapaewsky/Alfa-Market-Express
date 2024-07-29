//
//  Result.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 12.08.2024.
//

import Foundation


enum Result<T> {
    case success(_ response: T)
    case serverError(_ err: ErrorResponse)
    case authError(_ err: ErrorResponse)
    case networkError(_ err: String)
}
