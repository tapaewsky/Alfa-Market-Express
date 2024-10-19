//
//  CategoryViewModel.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 09.09.2024.
//

import Combine
import Foundation

class CategoryViewModel: ObservableObject {
    // MARK: - Properties
    @Published var categories: [Category] = []
    @Published var isLoading = false
    @Published var isError = false
    private let baseURL = "http://95.174.90.162:60/api/categories/"
    private var authManager = AuthManager.shared
//    private let categoriesKey = "cachedCategories"

    // MARK: - Initializer
//    init() {
//        loadCachedData()
//        fetchData { success in
//            if !success {
//                self.loadCachedData()
//            }
//        }
//    }

    // MARK: - Data Fetching
    func fetchCategory(completion: @escaping (Bool) -> Void) {
        guard let accessToken = authManager.accessToken else {
            print("Access token не найден.")
            completion(false)
            return
        }
        
        guard let url = URL(string: baseURL) else {
            print("Некорректный URL")
            completion(false)
            return
        }
        
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Ошибка при загрузке категорий: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }
            
            guard let data = data else {
                print("Ответ не содержит данных")
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }
            
            do {
                let categories = try JSONDecoder().decode([Category].self, from: data)
                
                DispatchQueue.main.async {
                    self.categories = categories
                    completion(true)
                }
            } catch {
                print("Ошибка при декодировании категорий: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }.resume()
    }
    

   

//    // MARK: - Caching
//    private func loadCachedData() {
//        if let categoriesData = UserDefaults.standard.data(forKey: categoriesKey),
//           let cachedCategories = try? JSONDecoder().decode([Category].self, from: categoriesData) {
//            categories = cachedCategories
//        }
//    }

//    private func saveCategories() {
//        if let data = try? JSONEncoder().encode(categories) {
//            UserDefaults.standard.set(data, forKey: categoriesKey)
//        }
//    }
}
