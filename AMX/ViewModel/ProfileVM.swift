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
    @Published private var navigateToProfile = false
    @Published private var navigateToRegistrationInfo = false
    var onProfileFetched: ((Bool) -> Void)?
    
//    private let baseURL = "https://113b-194-164-235-45.ngrok-free.app/api"
    var baseURL: String = BaseURL.alfa
    private let authManager = AuthManager.shared
    
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
            storeCode: 0,
            managerName: "",
            managerPhoneNumber: "",
            remainingDebt: "",
            favoriteProducts: []
        )
    }
    
//    func fetchUserProfile(completion: @escaping (Bool) -> Void) {
//        print("Начинаем запрос для получения профиля...")
//        isLoading = true
//        isError = false
//        
//        guard let url = URL(string: "\(baseURL)me/") else {
//            isLoading = false
//            isError = true
//            print("Ошибка: некорректный URL.")
//            completion(false)
//            return
//        }
//        
//        guard let accessToken = authManager.accessToken else {
//            isLoading = false
//            isError = true
//            print("Ошибка: отсутствует токен доступа.")
//            completion(false)
//            return
//        }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
//        
//        print("Отправляем запрос на сервер: \(url.absoluteString)")
//        
//        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
//            guard let self = self else { return }
//            
//            if let error = error {
//                DispatchQueue.main.async {
//                    self.isLoading = false
//                    self.isError = true
//                    print("Ошибка сети: \(error.localizedDescription)")
//                    completion(false)
//                }
//                return
//            }
//            
//            guard let httpResponse = response as? HTTPURLResponse else {
//                DispatchQueue.main.async {
//                    self.isLoading = false
//                    self.isError = true
//                    print("Ошибка: некорректный ответ от сервера.")
//                    completion(false)
//                }
//                return
//            }
//            
//            print("Код ответа от сервера: \(httpResponse.statusCode)")
//            
//            guard let data = data else {
//                DispatchQueue.main.async {
//                    self.isLoading = false
//                    self.isError = true
//                    print("Ошибка: нет данных в ответе.")
//                    completion(false)
//                }
//                return
//            }
//            
//            do {
//                print("Попытка декодировать данные в модель UserProfile.")
//                let userProfile = try JSONDecoder().decode(UserProfile.self, from: data)
//                
//                // Проверка значений firstName, lastName, storeAddress
//                DispatchQueue.main.async {
//                    if userProfile.firstName.isEmpty || userProfile.lastName.isEmpty || userProfile.storeAddress.isEmpty {
//                        self.isError = true
//                        print("Ошибка: обязательные поля отсутствуют.")
//                        completion(false)
//                    } else {
//                        print("Декодирование прошло успешно.")
//                        self.userProfile = userProfile
//                        self.isLoading = false
//                        completion(true)
//                    }
//                }
//            } catch {
//                DispatchQueue.main.async {
//                    self.isLoading = false
//                    self.isError = true
//                    print("Ошибка при декодировании данных: \(error.localizedDescription)")
//                    completion(false)
//                }
//            }
//        }.resume()
//    }
    
    func fetchUserProfile(completion: @escaping (Bool) -> Void) {
        print("Начинаем запрос для получения профиля...")
        isLoading = true
        isError = false
        
        guard let url = URL(string: "\(baseURL)me/") else {
            isLoading = false
            isError = true
            print("Ошибка: некорректный URL.")
            completion(false)
            return
        }
        
        guard let accessToken = authManager.accessToken else {
            isLoading = false
            isError = true
            print("Ошибка: отсутствует токен доступа.")
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        print("Отправляем запрос на сервер: \(url.absoluteString)")
        
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
                    print("Ошибка: некорректный ответ от сервера.")
                    completion(false)
                }
                return
            }
            
            print("Код ответа от сервера: \(httpResponse.statusCode)")
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.isError = true
                    print("Ошибка: нет данных в ответе.")
                    completion(false)
                }
                return
            }
            
            print("Ответ от сервера: \(String(data: data, encoding: .utf8) ?? "Нет данных")")
            
            do {
                print("Попытка декодировать данные в модель UserProfile.")
                let userProfile = try JSONDecoder().decode(UserProfile.self, from: data)
                
                DispatchQueue.main.async {
                    print("Декодирование прошло успешно.")
                    self.userProfile = userProfile
                    self.isLoading = false
                    
                    // Логи для получаемых данных
                    print("Полученные данные профиля: First Name: \(userProfile.firstName), Last Name: \(userProfile.lastName), Store Address: \(userProfile.storeAddress)")
                    
                    // Убедимся, что данные профиля получены перед проверкой
                    print("Проверяем, получены ли все данные: \(userProfile.firstName), \(userProfile.lastName), \(userProfile.storeAddress)")
                    
                    self.onProfileFetched?(true)
                    completion(true)
 
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.isError = true
                    print("Ошибка при декодировании данных: \(error.localizedDescription)")
                    completion(false)
                }
            }
        }.resume()
    }

 
    
    func updateProfile(completion: @escaping (Bool) -> Void) {
           guard let url = URL(string: "\(baseURL)me/update/"),
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
//               "store_name": userProfile.storeName,
               "store_address": userProfile.storeAddress
               
//               ,"store_phone": userProfile.storePhoneNumber
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
    
    func deleteProfile(completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)me/delete/"),
              let accessToken = authManager.accessToken else {
            print("Ошибка: некорректный URL или отсутствует токен доступа.")
            completion(false)
            return
        }
        
        print("Запрос на удаление профиля: \(url.absoluteString)")
        print("Токен доступа: \(accessToken)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Проверка на наличие ошибки
            if let error = error {
                print("Ошибка запроса: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }
            
            // Проверка кода ответа
            if let httpResponse = response as? HTTPURLResponse {
                let statusCode = httpResponse.statusCode
                if (200...299).contains(statusCode) {
                    print("Запрос выполнен успешно с кодом \(statusCode)")
                    DispatchQueue.main.async {
                        // Здесь вызываем logout после успешного удаления профиля
                        self.authManager.logOut()
                        completion(true)
                    }
                } else {
                    print("Ошибка сервера с кодом \(statusCode).")
                    DispatchQueue.main.async {
                        completion(false)
                    }
                }
            } else {
                print("Ошибка: Невозможно получить HTTP-ответ.")
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
        
        // Запуск запроса
        task.resume()
    }
}
