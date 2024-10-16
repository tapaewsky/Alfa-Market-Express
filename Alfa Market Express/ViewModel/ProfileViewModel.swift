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
    
    private let baseUrl = "http://95.174.90.162:60/api"

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
        
//        if AuthManager.shared.accessToken != nil {
//            loadUserProfile()
//        } else {
//            print("No access token")
//        }
//    }
//    
//    // MARK: - Profile Management
//    func loadUserProfile() {
//        fetchUserProfile { [weak self] success in
//            if !success {
//                AuthManager.shared.refreshAccessToken { [weak self] refreshed in
//                    if refreshed {
//                        self?.fetchUserProfile(completion: { _ in })
//                    } else {
//                        print("Failed to refresh token")
//                    }
//                }
//            }
//        }
    }
    func loadUserProfile() {
            fetchUserProfile { success in
                if !success {
                    // Здесь можно добавить логику для обработки ошибок, если нужно
                    print("Ошибка загрузки профиля")
                }
            }
        }
        
    
    private func fetchUserProfile(completion: @escaping (Bool) -> Void) {
        print("Запрос продуктов из ProfileViewModel")
        guard let url = URL(string: "\(baseUrl)/me/"),
              let token = AuthManager.shared.accessToken else {
            print("Invalid URL or no access token")
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
                print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
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
                print("Failed to decode JSON: \(error.localizedDescription)")
                completion(false)
            }
        }.resume()
    }
    
    // MARK: - User Authentication
    func authenticateUser(username: String, password: String, completion: @escaping (Bool) -> Void) {
        print("Attempting to authenticate with username: \(username)")
        
        guard let url = URL(string: "\(baseUrl)/token/") else {
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
        
        print("Sending request to server...")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            defer {
                DispatchQueue.main.async {
                    completion(false)
                }
            }
            
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                let responseDict = try JSONDecoder().decode([String: String].self, from: data)
                print("Server response: \(responseDict)")
                
                if let accessToken = responseDict["access"], let refreshToken = responseDict["refresh"] {
                    print("Tokens received: \(accessToken)")
                    AuthManager.shared.setTokens(accessToken: accessToken, refreshToken: refreshToken)
                    DispatchQueue.main.async {
                        completion(true)
                    }
                    return
                } else {
                    print("Invalid response format: \(responseDict)")
                }
            } catch {
                print("Failed to decode JSON: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    // MARK: - Profile Saving
    func saveProfile(completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseUrl)/me/"),
              let token = AuthManager.shared.accessToken else {
            print("Invalid URL or no access token")
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let jsonData = try JSONEncoder().encode(userProfile)
            request.httpBody = jsonData
        } catch {
            print("Error encoding profile data: \(error.localizedDescription)")
            completion(false)
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                print("Network error: \(error!.localizedDescription)")
                completion(false)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                print("Profile successfully updated")
                completion(true)
            } else {
                print("Error updating profile")
                completion(false)
            }
        }.resume()
    }
    
    // MARK: - Editing
    func toggleEditing() {
        isEditing.toggle()
    }
}
