//
//  AuthManager.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 23.08.2024.
//
import Foundation
import SwiftUI

class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    @Published var isAuthenticated: Bool = false
    @Published var isCheckingAuth: Bool = true

    private let accessTokenKey = "accessToken"
    private let refreshTokenKey = "refreshToken"
    
    var accessToken: String? {
        UserDefaults.standard.string(forKey: accessTokenKey)
    }
    
    var refreshToken: String? {
        UserDefaults.standard.string(forKey: refreshTokenKey)
    }
    
    func checkAuthentication() {
        DispatchQueue.global().async {
            if self.accessToken != nil {
                DispatchQueue.main.async {
                    self.isAuthenticated = true
                    self.isCheckingAuth = false
                }
            } else {
                self.refreshAccessToken { success in
                    DispatchQueue.main.async {
                        self.isAuthenticated = success
                        self.isCheckingAuth = false
                    }
                }
            }
        }
    }
    
    func refreshAccessToken(completion: @escaping (Bool) -> Void) {
        guard let refreshToken = self.refreshToken else {
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
                    UserDefaults.standard.set(newAccessToken, forKey: self.accessTokenKey)
                    completion(true)
                } else {
                    completion(false)
                }
            } catch {
                completion(false)
            }
        }.resume()
    }
    
    // Метод для установки токенов
    func setTokens(accessToken: String, refreshToken: String) {
        UserDefaults.standard.set(accessToken, forKey: accessTokenKey)
        UserDefaults.standard.set(refreshToken, forKey: refreshTokenKey)
    }
    
    // Метод для удаления токенов
    func clearTokens() {
        UserDefaults.standard.removeObject(forKey: accessTokenKey)
        UserDefaults.standard.removeObject(forKey: refreshTokenKey)
    }
}
