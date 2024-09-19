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
    @Published var isLoading = false
    @Published var isError = false

    private let categoriesKey = "cachedCategories"

    init() {
        loadCachedData()
        fetchData { success in
            if !success {
                self.loadCachedData()
            }
        }
    }

    func fetchData(completion: @escaping (Bool) -> Void) {
        isLoading = true
        isError = false
        
        let dispatchGroup = DispatchGroup()
        var success = true
        
        dispatchGroup.enter()
        fetchCategories { fetchCategoriesSuccess in
            success = success && fetchCategoriesSuccess
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            self.isLoading = false
            self.isError = !success
            completion(success)
        }
    }

    private func loadCachedData() {
        if let categoriesData = UserDefaults.standard.data(forKey: categoriesKey),
           let cachedCategories = try? JSONDecoder().decode([Category].self, from: categoriesData) {
            categories = cachedCategories
        }
    }

    func fetchCategories(completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "http://95.174.90.162:60/api/categories/") else {
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
                    self.saveCategories()
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
}
