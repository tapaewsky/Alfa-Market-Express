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
    @Published var selectedImage: UIImage? = nil
    
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
    }

    // MARK: - Получение профиля пользователя
    func fetchUserProfile(completion: @escaping (Bool) -> Void) {
        isLoading = true
        isError = false

        guard let token = authManager.accessToken else {
            print("Токен доступа не найден, обновляем токен")
            authManager.refreshAccessToken { [weak self] success in
                if success {
                    self?.fetchUserProfile(completion: completion)
                } else {
                    self?.isLoading = false
                    self?.isError = true
                    completion(false)
                }
            }
            return
        }

        guard let url = URL(string: "\(baseURL)/me/") else {
            isLoading = false
            isError = true
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }

            if let error = error {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.isError = true
                    print("Ошибка сети: \(error.localizedDescription)")
                    completion(false)
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.isError = true
                    completion(false)
                }
                return
            }

            if httpResponse.statusCode == 401 {
                self.authManager.refreshAccessToken { success in
                    if success {
                        self.fetchUserProfile(completion: completion)
                    } else {
                        DispatchQueue.main.async {
                            self.isLoading = false
                            self.isError = true
                            completion(false)
                        }
                    }
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.isError = true
                    completion(false)
                }
                return
            }

            do {
                let userProfile = try JSONDecoder().decode(UserProfile.self, from: data)
                DispatchQueue.main.async {
                    self.userProfile = userProfile
                    self.isLoading = false
                    completion(true)
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.isError = true
                    completion(false)
                }
            }
        }.resume()
    }

    // MARK: - Обновление профиля
    func updateProfile(completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/me/update/"),
              let accessToken = authManager.accessToken else {
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        if let selectedImage = selectedImage {
            let imageData = selectedImage.jpegData(compressionQuality: 0.8)
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"store_image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData!)
            body.append("\r\n".data(using: .utf8)!)
        }
        
        let textFields: [String: String] = [
            "first_name": userProfile.firstName,
            "last_name": userProfile.lastName,
            "store_name": userProfile.storeName,
            "store_address": userProfile.storeAddress,
            "store_phone": userProfile.storePhoneNumber
        ]
        
        for (key, value) in textFields {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                completion((200...299).contains(httpResponse.statusCode))
            } else {
                completion(false)
            }
        }.resume()
    }

    // MARK: - Переключение режима редактирования
    func toggleEditing() {
        isEditing.toggle()
    }
}
