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

    private let categoriesKey = "cachedCategories"

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
        print("Запрос категорий из CategoryViewModel")
        isLoading = true
        isError = false

        guard let url = URL(string: "http://95.174.90.162:60/api/categories/") else {
            print("Неверный URL")
            isLoading = false
            isError = true
            completion(false)
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                print("Ошибка при получении категорий: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self?.isLoading = false
                    self?.isError = true
                    completion(false)
                }
                return
            }

            guard let data = data else {
                print("Нет данных в ответе")
                DispatchQueue.main.async {
                    self?.isLoading = false
                    self?.isError = true
                    completion(false)
                }
                return
            }

            do {
                let categories = try JSONDecoder().decode([Category].self, from: data)
                DispatchQueue.main.async {
                    self?.categories = categories
                    self?.saveCategories() // Кэширование категорий, если нужно
                    self?.isLoading = false
                    completion(true)
                }
            } catch {
                print("Ошибка декодирования категорий: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self?.isLoading = false
                    self?.isError = true
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

    private func saveCategories() {
        if let data = try? JSONEncoder().encode(categories) {
            UserDefaults.standard.set(data, forKey: categoriesKey)
        }
    }
}
