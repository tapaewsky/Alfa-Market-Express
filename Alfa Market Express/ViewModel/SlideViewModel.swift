//
//  SlideViewModel.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 16.10.2024.
//

import Foundation
import Combine

class SlideViewModel: ObservableObject {
    @Published var slides: [Slide] = []
    private let authManager: AuthManager
    private let baseURL = "http://95.174.90.162:60/api/sliders/"
    
    init(authManager: AuthManager) {
        self.authManager = authManager
//        fetchSlides(completion: { _ in }) 
    }
    
    func fetchSlides(completion: @escaping (Bool) -> Void) {
        guard let accessToken = authManager.accessToken else {
            print("Access token not found.")
            completion(false)
            return
        }
        
        guard let url = URL(string: baseURL) else {
            print("Неверный URL")
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("Ошибка при получении слайдов: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }

            guard let data = data else {
                print("Нет данных в ответе")
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }

            do {
                let slides = try JSONDecoder().decode([Slide].self, from: data)
                DispatchQueue.main.async {
                    self?.slides = slides // Обновление локального массива
                    completion(true)
                }
            } catch {
                print("Ошибка декодирования слайдов: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }.resume()
    }

}
