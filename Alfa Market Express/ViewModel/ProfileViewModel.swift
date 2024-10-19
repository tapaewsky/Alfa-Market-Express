//
//  ProfileViewModel.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 15.08.2024.
//

import SwiftUI

class ProfileViewModel: ObservableObject {
    // MARK: - Properties
    @Published var userProfile: UserProfile
    @Published var isEditing: Bool = false
    @Published var isLoading = false
    @Published var isError = false
    private let baseURL = "http://95.174.90.162:60/api"
    private let authManager = AuthManager.shared
    
    // MARK: - Initializer
    init() {
        self.userProfile = UserProfile(
            id: 0,
            username: "",
            firstName: "",
            lastName: "",
            storeName: "",
            storeImageUrl: "https://via.placeholder.com/150",
            storeAddress: "",
            storePhoneNumber: "",
            storeCode: "",
            managerName: "",
            managerPhoneNumber: "",
            remainingDebt: "",
            favoriteProducts: []
        )
        print("ProfileViewModel initialized with user profile: \(userProfile)")
    }
    
    private func refreshTokenAndRetry() {
        print("Refreshing token and retrying...")
        AuthManager.shared.refreshAccessToken { [weak self] refreshed in
            if refreshed {
                print("Token refreshed successfully.")
                self?.fetchUserProfile(completion: { _ in })
            } else {
                print("Failed to refresh token.")
            }
        }
    }
    
    func fetchUserProfile(completion: @escaping (Bool) -> Void) {
        guard let accessToken = authManager.accessToken else {
            print("Отсутствует токен доступа")
            completion(false)
            return
        }
        
        guard let url = URL(string: "\(baseURL)/me/") else {
            print("Неверный URL")
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        print("Fetching user profile with URL: \(url) and token: \(accessToken)")
        
        isLoading = true
        isError = false
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            defer { self?.isLoading = false }
            
            if let error = error {
                print("Ошибка при получении данных: \(error.localizedDescription)")
                self?.isError = true
                completion(false)
                return
            }
            
            guard let data = data else {
                print("Нет данных в ответе")
                self?.isError = true
                completion(false)
                return
            }
            
            print("Получены данные профиля: \(String(data: data, encoding: .utf8) ?? "Нет данных")")
            
            do {
                let userProfile = try JSONDecoder().decode(UserProfile.self, from: data)
                DispatchQueue.main.async {
                    self?.userProfile = userProfile
                    print("Профиль пользователя успешно обновлен: \(userProfile)")
                    completion(true)
                }
            } catch {
                print("Не удалось декодировать JSON: \(error.localizedDescription)")
                self?.isError = true
                completion(false)
            }
        }.resume()
    }
    
    // MARK: - Profile Saving
    func updateProfile(completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "http://95.174.90.162:60/api/me/update/") else {
            print("Invalid URL")
            return
        }
        
        
        guard let accessToken = authManager.accessToken else {
            print("Отсутствует токен доступа")
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let profileData: [String: Any] = [
            "storePhoneNumber": userProfile.storePhoneNumber,
            "firstName": userProfile.firstName,
            "storeAddress": userProfile.storeAddress,
            "storeName": userProfile.storeName,
            "username": userProfile.username,
            "lastName": userProfile.lastName
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: profileData, options: [])
            request.httpBody = jsonData
            print("Отправка данных в формате JSON: \(String(data: jsonData, encoding: .utf8) ?? "")")
        } catch {
            print("Ошибка сериализации JSON: \(error)")
            completion(false)
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Ошибка при обновлении профиля: \(error)")
                completion(false)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode == 200 || httpResponse.statusCode == 204 {
                    // Обработка успешного ответа
                    if let data = data {
                        do {
                            let profileResponse = try JSONDecoder().decode(UserProfile.self, from: data)
                            DispatchQueue.main.async {
                                self.userProfile = profileResponse
                                print("Профиль успешно обновлен: \(profileResponse)")
                                completion(true)
                            }
                        } catch {
                            print("Ошибка декодирования профиля: \(error)")
                            completion(false)
                        }
                    } else {
                        print("Нет данных в ответе")
                        completion(false)
                    }
                } else {
                    print("Ошибка обновления профиля: \(httpResponse.statusCode)")
                    completion(false)
                }
            }
            
        }
    }
        

       
    


    private func createRequest(url: URL, method: String, token: String) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        print("Создан запрос: \(request)")
        return request
    }
    
    // MARK: - Editing
    func toggleEditing() {
        isEditing.toggle()
        print("Editing toggled: \(isEditing)")
    }
}
