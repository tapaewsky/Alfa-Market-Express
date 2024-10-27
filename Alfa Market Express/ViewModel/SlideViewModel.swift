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
    
    private let baseURL = "http://95.174.90.162:60/api/sliders/"
    
    func fetchSlides(completion: @escaping (Bool) -> Void) {
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
