//
//  AuthManager.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 23.08.2024.
//
import Foundation
import SwiftUI

class AuthManager: ObservableObject {
    // MARK: - Singleton Instance
    static let shared = AuthManager()
    
    // MARK: - Properties
    @Published var isAuthenticated: Bool = false
    @Published var isCheckingAuth: Bool = true

    private let accessTokenKey = "accessToken"
    private let refreshTokenKey = "refreshToken"
    
    private let baseUrl = "http://95.174.90.162:60/api"
    
    var accessToken: String? {
        UserDefaults.standard.string(forKey: accessTokenKey)
    }
    
    var refreshToken: String? {
        UserDefaults.standard.string(forKey: refreshTokenKey)
    }

    // MARK: - Проверка аутентификации
    func checkAuthentication() {
        DispatchQueue.global().async {
            if let token = self.accessToken {
                print("Токен существует: \(token)")
                DispatchQueue.main.async {
                    self.isAuthenticated = true
                    self.isCheckingAuth = false
                }
            } else {
                print("Токен не найден, попытка обновить токен...")
                self.refreshAccessToken { success in
                    DispatchQueue.main.async {
                        if success {
                            print("Токен успешно обновлён")
                            self.isAuthenticated = true
                        } else {
                            print("Не удалось обновить токен")
                            self.isAuthenticated = false
                        }
                        self.isCheckingAuth = false
                    }
                }
            }
        }
    }
    
    // MARK: - Обновление токена
    func refreshAccessToken(completion: @escaping (Bool) -> Void) {
        guard let refreshToken = self.refreshToken else {
            print("Refresh-токен не найден")
            completion(false)
            return
        }
        
        let url = URL(string: "\(baseUrl)/token/refresh/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = ["refresh": refreshToken]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Ошибка при обновлении токена: \(error?.localizedDescription ?? "Неизвестная ошибка")")
                completion(false)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let newAccessToken = json["access"] as? String {
                    UserDefaults.standard.set(newAccessToken, forKey: self.accessTokenKey)
                    print("Новый токен получен: \(newAccessToken)")
                    completion(true)
                } else {
                    print("Некорректный формат ответа при обновлении токена")
                    completion(false)
                }
            } catch {
                print("Ошибка при декодировании ответа: \(error.localizedDescription)")
                completion(false)
            }
        }.resume()
    }

    // MARK: - Аутентификация пользователя
    func authenticateUser(username: String, password: String, completion: @escaping (Bool) -> Void) {
        print("Аутентификация пользователя...")

        // Проверка корректности URL
        guard let url = URL(string: "\(baseUrl)/token/") else {
            print("Некорректный URL")
            completion(false)
            return
        }

        // Формируем тело запроса с логином и паролем
        let body: [String: String] = ["username": username, "password": password]
        
        // Сериализация тела запроса
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            print("Ошибка сериализации JSON")
            completion(false)
            return
        }

        // Создаем запрос
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        // Выполняем запрос
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Ошибка: \(error?.localizedDescription ?? "Неизвестная ошибка")")
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
                    print("Некорректный формат ответа")
                    completion(false)
                }
            } catch {
                print("Ошибка декодирования JSON: \(error.localizedDescription)")
                completion(false)
            }
        }.resume()
    }

    // MARK: - Получение токена (асинхронно)
    func getToken() async -> String? {
        var token = accessToken
        if token == nil {
            print("Токен не найден, попытка обновить токен...")
            let success = await withCheckedContinuation { continuation in
                refreshAccessToken { success in
                    continuation.resume(returning: success)
                }
            }
            if success {
                token = accessToken
            } else {
                token = nil
            }
        }

        return token
    }
    
    // MARK: - Управление токенами
    func setTokens(accessToken: String, refreshToken: String) {
        UserDefaults.standard.set(accessToken, forKey: accessTokenKey)
        UserDefaults.standard.set(refreshToken, forKey: refreshTokenKey)
    }
    
    func clearTokens() {
        UserDefaults.standard.removeObject(forKey: accessTokenKey)
        UserDefaults.standard.removeObject(forKey: refreshTokenKey)
    }
}
