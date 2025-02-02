//
//  ProfileVM.swift
//  AlfaMarketExpress
//
//  Created by Said Tapaev on 24.12.2024.
//

import SwiftUI

class ProfileViewModel: ObservableObject {
    @Published var userProfile: UserProfile
    @Published var isEditing: Bool = false
    @Published var isLoading = false
    @Published var isError = false
    @Published var selectedImage: UIImage? = nil
    
    private let baseURL = "https://77d4-194-164-235-45.ngrok-free.app/api"
    private let authManager = AuthManager.shared
    
    init() {
        self.userProfile = UserProfile(
            id: 0,
            username: "",
            firstName: "",
            lastName: "",
            storeImageUrl: "https://via.placeholder.com/150",
            storeAddress: "",
            storePhoneNumber: "",
            storeCode: "",
            remainingDebt: "",
            favoriteProducts: []
        )
    }
    
    func fetchUserProfile(completion: @escaping (Bool) -> Void) {
        isLoading = true
        isError = false
        
        guard let url = URL(string: "\(baseURL)/me/") else {
            isLoading = false
            isError = true
            completion(false)
            return
        }
        
        guard let accessToken = authManager.accessToken else {
            // Проверка на nil для accessToken
            isLoading = false
            isError = true
            print("Ошибка: отсутствует токен доступа.")
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        print("Запрос на сервер: \(url.absoluteString)")
        
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
    
    func updateProfile(completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/me/update/"),
              let accessToken = authManager.accessToken else {
            print("Ошибка: некорректный URL или отсутствует токен доступа.")
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        print("Запрос на обновление профиля отправляется на сервер: \(url.absoluteString)")
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        if let selectedImage = selectedImage {
            print("Изображение для профиля выбрано. Сжимаем изображение.")
            if let compressedImageData = selectedImage.jpegData(compressionQuality: 0.5) {
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"store_image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
                body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
                body.append(compressedImageData)
                body.append("\r\n".data(using: .utf8)!)
            } else {
                print("Ошибка: невозможно сжать выбранное изображение.")
            }
        }
        
        let textFields: [String: String] = [
            "first_name": userProfile.firstName,
            "last_name": userProfile.lastName,
            "store_address": userProfile.storeAddress,
            "store_phone": userProfile.storePhoneNumber
        ]
        
        for (key, value) in textFields {
            print("Добавляем поле: \(key) = \(value)")
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        print("Тело запроса сформировано. Отправка данных.")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Ошибка сети при обновлении профиля: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Код ответа сервера: \(httpResponse.statusCode)")
                if (200...299).contains(httpResponse.statusCode) {
                    print("Обновление профиля прошло успешно.")
                    completion(true)
                } else {
                    print("Ошибка обновления профиля. Код ответа: \(httpResponse.statusCode)")
                    completion(false)
                }
            } else {
                print("Ошибка: некорректный ответ от сервера.")
                completion(false)
            }
        }.resume()
    }
}

