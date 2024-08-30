//
//  AuthManager.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 23.08.2024.
//

import Foundation

class AuthManager {
    static let shared = AuthManager()
    
    private let accessTokenKey = "accessToken"
    private let refreshTokenKey = "refreshToken"
    
    var accessToken: String? {
        get {
            UserDefaults.standard.string(forKey: accessTokenKey)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: accessTokenKey)
        }
    }
    
    var refreshToken: String? {
        get {
            UserDefaults.standard.string(forKey: refreshTokenKey)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: refreshTokenKey)
        }
    }
    
    func refreshAccessToken(completion: @escaping (Bool) -> Void) {
        guard let refreshToken = refreshToken else {
            completion(false)
            return
        }
        
        let url = URL(string: "http://95.174.90.162:8000/api/token/refresh/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = ["refresh": refreshToken]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(false)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let newAccessToken = json["access"] as? String {
                    self.accessToken = newAccessToken
                    completion(true)
                } else {
                    completion(false)
                }
            } catch {
                completion(false)
            }
        }.resume()
    }
}
