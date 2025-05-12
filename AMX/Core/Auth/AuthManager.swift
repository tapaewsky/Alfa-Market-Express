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
        print("Токен доступа: \(accessToken)")
    }

    func checkAuthentication() {
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }

            if let accessToken = self.accessToken {
                // Проверяем валидность токена, делая запрос на сервер
                self.verifyToken { isValid in
                    DispatchQueue.main.async {
                        if isValid {
                            print("Access token is valid: \(accessToken)")
                            self.isAuthenticated = true
                        } else {
                            print("Access token is invalid")
                            self.isAuthenticated = false
                            self.refreshAccessToken { success in
                                DispatchQueue.main.async {
                                    self.isAuthenticated = true
                                    if success {
                                        print("Token successfully refreshed")
                                    } else {
                                        print("Failed to refresh token")
                                        self.clearTokens()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private func verifyToken(completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)me") else {
            completion(false)
            return
        }
        guard let accessToken else {
            print("Ошибка: отсутствует токен доступа.")
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error {
                print("Error verifying token: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }

            switch httpResponse.statusCode {
                case 200:
                    DispatchQueue.main.async {
                        completion(true)
                    }
                case 401:
                    DispatchQueue.main.async {
//                    self.clearTokens()
                        completion(false)
                    }
                default:
                    DispatchQueue.main.async {
                        completion(false)
                    }
            }
        }.resume()
    }

    func refreshAccessToken(completion: @escaping (Bool) -> Void) {
        guard let refreshToken else {
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

        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data, error == nil else {
                print("Error refreshing token: \(error?.localizedDescription ?? "Unknown error")")
                completion(false)
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let newAccessToken = json["access"] as? String
                {
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

        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data, error == nil else {
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

        DispatchQueue.global(qos: .userInitiated).async {
            // Очищаем токены и кэш в фоновом потоке
            self.clearTokens()
            self.clearAppCache()

            // Все изменения состояния должны происходить в главном потоке
            DispatchQueue.main.async {
                self.isAuthenticated = false
                print("Выход успешен")
            }
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
