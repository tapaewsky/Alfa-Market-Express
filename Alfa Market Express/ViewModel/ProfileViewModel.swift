//
//  ProfileViewModel.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 15.08.2024.
//

import SwiftUI

class ProfileViewModel: ObservableObject {
    @Published var userProfile: UserProfile
    @Published var isEditing: Bool = false
    
    init() {
        self.userProfile = UserProfile(
            id: 0,
            username: "",
            firstName: "",
            lastName: "",
            storeName: "",
            storeImageUrl: "https://via.placeholder.com/100",
            storeAddress: "",
            storePhoneNumber: "",
            storeCode: "",
            managerName: "",
            managerPhoneNumber: "",
            remainingDebt: "",
            favoriteProducts: []
        )
        
        if AuthManager.shared.accessToken != nil {
            loadUserProfile()
        } else {
            print("Нет токена доступа")
        }
    }
    
    func toggleEditing() {
        isEditing.toggle()
    }
    
    func loadUserProfile() {
        fetchUserProfile { [weak self] success in
            if !success {
                AuthManager.shared.refreshAccessToken { [weak self] refreshed in
                    if refreshed {
                        self?.fetchUserProfile(completion: { _ in })
                    } else {
                        print("Не удалось обновить токен")
                    }
                }
            }
        }
    }
    
    private func fetchUserProfile(completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "http://95.174.90.162:60/api/me/"),
              let token = AuthManager.shared.accessToken else {
            print("Неверный URL или нет токена доступа")
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
                print("HTTP Headers: \(httpResponse.allHeaderFields)")
            }
            
            guard let data = data, error == nil else {
                print("Ошибка при получении данных: \(error?.localizedDescription ?? "Неизвестная ошибка")")
                completion(false)
                return
            }
            
            do {
                let userProfile = try JSONDecoder().decode(UserProfile.self, from: data)
                DispatchQueue.main.async {
                    self?.userProfile = userProfile
                    completion(true)
                }
            } catch {
                print("Не удалось декодировать JSON: \(error.localizedDescription)")
                completion(false)
            }
        }.resume()
    }
    
    func authenticateUser(username: String, password: String, completion: @escaping (Bool) -> Void) {
        print("Начата попытка аутентификации с именем пользователя: \(username)")
        
        guard let url = URL(string: "http://95.174.90.162:60/api/token/") else {
            print("Неверный URL")
            completion(false)
            return
        }
        
        let body: [String: String] = ["username": username, "password": password]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            print("Не удалось сериализовать JSON")
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        print("Отправка запроса на сервер...")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            defer {
                DispatchQueue.main.async {
                    completion(false)
                }
            }
            
            if let error = error {
                print("Ошибка при получении данных: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("Данные отсутствуют")
                return
            }
            
            do {
                let responseDict = try JSONDecoder().decode([String: String].self, from: data)
                print("Ответ сервера: \(responseDict)")
                
                if let accessToken = responseDict["access"], let refreshToken = responseDict["refresh"] {
                    print("Токены получены: \(accessToken)")
                    AuthManager.shared.setTokens(accessToken: accessToken, refreshToken: refreshToken)
                    DispatchQueue.main.async {
                        completion(true)
                    }
                    return  
                } else {
                    print("Неверный формат ответа: \(responseDict)")
                }
            } catch {
                print("Не удалось декодировать JSON: \(error.localizedDescription)")
            }
        }.resume()
    }
}
