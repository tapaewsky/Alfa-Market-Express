//
//  AuthManager.swift
//  AlfaMarketExpress
//
//  Created by Said Tapaev on 24.12.2024.
//

import Foundation
import SwiftUI

class AuthManager: ObservableObject {
    static let shared = AuthManager()

    @Published var isAuthenticated: Bool = false
    @Published var isCheckingAuth: Bool = true

    private let accessTokenKey = "accessToken"
    private let refreshTokenKey = "refreshToken"
//    private let baseUrl = "https://113b-194-164-235-45.ngrok-free.app/api"
    
    var baseURL: String = BaseURL.alfa
    var accessToken: String? {
        UserDefaults.standard.string(forKey: accessTokenKey)
    }
    
    var refreshToken: String? {
        UserDefaults.standard.string(forKey: refreshTokenKey)
    }

    init() {
        checkAuthentication()
    }

    func checkAuthentication() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            if let token = self.accessToken {
                print("Access token exists: \(token)")
                DispatchQueue.main.async {
                    self.isAuthenticated = true
                    self.isCheckingAuth = false
                }
            } else if let refreshToken = self.refreshToken {
                print("Access token not found, trying to refresh...")
                self.refreshAccessToken { success in
                    DispatchQueue.main.async {
                        self.isAuthenticated = success
                        self.isCheckingAuth = false
                        if success {
                            print("Token successfully refreshed")
                        } else {
                            print("Failed to refresh token")
                            self.clearTokens()
                        }
                    }
                }
            } else {
                print("No access or refresh token found, showing LoginView")
                DispatchQueue.main.async {
                    self.clearTokens()
                    self.isAuthenticated = false
                    self.isCheckingAuth = false
                }
            }
        }
    }

    func refreshAccessToken(completion: @escaping (Bool) -> Void) {
        guard let refreshToken = self.refreshToken else {
            print("Refresh token not found")
            completion(false)
            return
        }

        let url = URL(string: "\(baseURL)token/refresh/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = ["refresh": refreshToken]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        print("Запрос на сервер: \(url.absoluteString)")

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error refreshing token: \(error?.localizedDescription ?? "Unknown error")")
                completion(false)
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let newAccessToken = json["access"] as? String {
                    UserDefaults.standard.set(newAccessToken, forKey: self.accessTokenKey)
                    print("New token received: \(newAccessToken)")
                    completion(true)
                } else {
                    print("Invalid response format during token refresh")
                    completion(false)
                }
            } catch {
                print("Failed to decode response: \(error.localizedDescription)")
                completion(false)
            }
        }.resume()
    }

    func authenticateUser(username: String, password: String, completion: @escaping (Bool) -> Void) {
        print("Authenticating user...")

        guard let url = URL(string: "\(baseURL)token/") else {
            print("Invalid URL")
            completion(false)
            return
        }

        let body: [String: String] = ["username": username, "password": password]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            print("Failed to serialize JSON")
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        print("Запрос на сервер: \(url.absoluteString)")

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                completion(false)
                return
            }

            do {
                let responseDict = try JSONDecoder().decode([String: String].self, from: data)
                if let accessToken = responseDict["access"], let refreshToken = responseDict["refresh"] {
                    AuthManager.shared.setTokens(accessToken: accessToken, refreshToken: refreshToken)
                    DispatchQueue.main.async {
                        completion(true)
                    }
                } else {
                    print("Invalid response format")
                    completion(false)
                }
            } catch {
                print("Failed to decode JSON: \(error.localizedDescription)")
                completion(false)
            }
        }.resume()
    }

    func getToken() async -> String? {
        var token = accessToken
        if token == nil {
            print("Token not found, trying to refresh...")
            let success = await withCheckedContinuation { continuation in
                refreshAccessToken { success in
                    continuation.resume(returning: success)
                }
            }
            if success {
                token = accessToken
            }
        }
        return token
    }

    func setTokens(accessToken: String, refreshToken: String) {
        UserDefaults.standard.set(accessToken, forKey: accessTokenKey)
        UserDefaults.standard.set(refreshToken, forKey: refreshTokenKey)
    }

    func clearTokens() {
        UserDefaults.standard.removeObject(forKey: accessTokenKey)
        UserDefaults.standard.removeObject(forKey: refreshTokenKey)
    }

    func logOut() {
        print("Logging out...")
        clearTokens()
        clearAppCache()
        
        DispatchQueue.main.async {
            self.isAuthenticated = false
            self.isCheckingAuth = false
        }
    }
    
    func clearAppCache() {
        // Очистка данных в UserDefaults
        let userDefaults = UserDefaults.standard
        let dictionary = userDefaults.dictionaryRepresentation()
        for key in dictionary.keys {
            userDefaults.removeObject(forKey: key)
        }

        // Очистка кэшированных файлов (например, изображения)
        clearCachedFiles()

    }

    func clearCachedFiles() {
        // Путь к кэшированным файлам (например, для изображений)
        let fileManager = FileManager.default
        if let cachesDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first {
            do {
                let files = try fileManager.contentsOfDirectory(at: cachesDirectory, includingPropertiesForKeys: nil)
                for file in files {
                    try fileManager.removeItem(at: file)
                }
            } catch {
                print("Error clearing cached files: \(error)")
            }
        }
    }

}
