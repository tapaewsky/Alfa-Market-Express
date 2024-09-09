//
//  CategoryViewModel.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 09.09.2024.
//

import Combine
import Foundation

class CategoryViewModel: ObservableObject {
    @Published var categories: [Category] = []

    private let categoriesKey = "cachedCategories"

    init() {
        loadCategories() 
    }

    func fetchCategories(completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "http://95.174.90.162:8000/api/categories/") else {
            completion(false)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching categories: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }
            
            guard let data = data else {
                print("No data received")
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }
            
            do {
                let categories = try JSONDecoder().decode([Category].self, from: data)
                DispatchQueue.main.async {
                    self.categories = categories
                    self.saveCategories() // Сохранение категорий после успешного получения данных
                    completion(true)
                }
            } catch {
                print("Error decoding categories: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }.resume()
    }

    private func saveCategories() {
        if let data = try? JSONEncoder().encode(categories) {
            UserDefaults.standard.set(data, forKey: categoriesKey)
        }
    }

    private func loadCategories() {
        if let data = UserDefaults.standard.data(forKey: categoriesKey),
           let savedCategories = try? JSONDecoder().decode([Category].self, from: data) {
            self.categories = savedCategories
        }
    }
}
