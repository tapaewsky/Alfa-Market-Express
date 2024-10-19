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
    }
    
    private func refreshTokenAndRetry() {
        AuthManager.shared.refreshAccessToken { [weak self] refreshed in
            if refreshed {
                self?.fetchUserProfile(completion: { _ in })
            }
        }
    }
    
    func fetchUserProfile(completion: @escaping (Bool) -> Void) {
        isLoading = true
        isError = false
        
        guard let url = URL(string: "\(baseURL)/me/"),
              let token = AuthManager.shared.accessToken else {
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
            
            if error != nil || data == nil {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.isError = true
                    completion(false)
                }
                return
            }

            do {
                let userProfile = try JSONDecoder().decode(UserProfile.self, from: data!)
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

    // MARK: - Profile Saving
    func updateProfile(completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/me/update/"),
              let accessToken = authManager.accessToken else {
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = [
            "first_name": userProfile.firstName.trimmingCharacters(in: .whitespaces),
            "last_name": userProfile.lastName.trimmingCharacters(in: .whitespaces),
            "store_name": userProfile.storeName.trimmingCharacters(in: .whitespaces),
            "store_address": userProfile.storeAddress.trimmingCharacters(in: .whitespaces),
            "store_phone": userProfile.storePhoneNumber.trimmingCharacters(in: .whitespaces)
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                completion((200...299).contains(httpResponse.statusCode))
            } else {
                completion(false)
            }
        }
        task.resume()
    }

    // MARK: - Editing
    func toggleEditing() {
        isEditing.toggle()
    }
}
