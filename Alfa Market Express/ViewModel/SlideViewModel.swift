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
    @Published var isLoading = false
    @Published var isError = false
    private let baseURL = "https://alfamarketexpress.ru/api/sliders/"
    
    private let slidesCacheKey = "cachedSlides"
    private let lastUpdatedKey = "lastUpdatedSlides"
    
    func fetchSlides(completion: @escaping (Bool) -> Void) {
        // Проверяем, если данные в кэше актуальны (например, данные обновлялись менее 1 дня назад)
        if let lastUpdated = UserDefaults.standard.object(forKey: lastUpdatedKey) as? Date,
           Date().timeIntervalSince(lastUpdated) < 86400, // 24 часа
           let cachedData = UserDefaults.standard.data(forKey: slidesCacheKey),
           let cachedSlides = try? JSONDecoder().decode([Slide].self, from: cachedData) {
            // Используем кэшированные данные, если они актуальны
            self.slides = cachedSlides
            completion(true)
        } else {
            // Если кэш устарел, загружаем с сервера
            loadSlidesFromServer(completion: completion)
        }
    }

    private func loadSlidesFromServer(completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: baseURL) else {
            print("Неверный URL")
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        isLoading = true
        isError = false
        
        print("Запрос на сервер: \(url.absoluteString)")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            defer { self?.isLoading = false }
            
            if let error = error {
                print("Ошибка при получении слайдов: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self?.isError = true
                    completion(false)
                }
                return
            }
            
            guard let data = data else {
                print("Нет данных в ответе")
                DispatchQueue.main.async {
                    self?.isError = true
                    completion(false)
                }
                return
            }
            
            do {
                let slides = try JSONDecoder().decode([Slide].self, from: data)
                
                // Сохраняем данные в кэш
                if let slidesCacheKey = self?.slidesCacheKey {
                    UserDefaults.standard.set(data, forKey: slidesCacheKey)
                }
                
                // Сохраняем дату последнего обновления
                UserDefaults.standard.set(Date(), forKey: self?.lastUpdatedKey ?? "lastUpdatedSlides")
                
                DispatchQueue.main.async {
                    self?.slides = slides
                    completion(true)
                }
            } catch {
                print("Ошибка декодирования слайдов: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self?.isError = true
                    completion(false)
                }
            }
        }.resume()
    }
}
