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
    private let baseURL = "http://95.174.90.162:60/api/categories/"

    func fetchCategory(completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: baseURL) else {
            print("Некорректный URL")
            completion(false)
            return
        }

        isLoading = true
        print("Запрос на сервер: \(url.absoluteString)")

        URLSession.shared.dataTask(with: URLRequest(url: url)) { data, response, error in
            if let error = error {
                print("Ошибка при загрузке категорий: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.isError = true
                    completion(false)
                }
                return
            }

            guard let data = data else {
                print("Ответ не содержит данных")
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.isError = true
                    completion(false)
                }
                return
            }

            do {
                let categories = try JSONDecoder().decode([Category].self, from: data)
                DispatchQueue.main.async {
                    self.categories = categories
                  
                    self.isLoading = false
                    completion(true)
                }
            } catch {
                print("Ошибка при декодировании категорий: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.isError = true
                    completion(false)
                }
            }
        }.resume()
    }
}
