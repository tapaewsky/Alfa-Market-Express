//
//  SlideVM.swift
//  AlfaMarketExpress
//
//  Created by Said Tapaev on 24.12.2024.
//

import Combine

// import Foundation
// import Combine
//
// class SlideViewModel: ObservableObject {
//    @Published var slides: [Slide] = []
//    @Published var isLoading = false
//    @Published var isError = false
////    private let baseURL = "https://alfamarketexpress.ru/api/sliders/"
//    var baseURL: String = BaseURL.alfa + "sliders/"
//
//    func fetchSlides(completion: @escaping (Bool) -> Void) {
//        loadSlidesFromServer(completion: completion)
//    }
//
//    private func loadSlidesFromServer(completion: @escaping (Bool) -> Void) {
//        guard let url = URL(string: baseURL) else {
//            print("Неверный URL")
//            completion(false)
//            return
//        }
//
//        var request = URLRequest(url: url)
//        isLoading = true
//        isError = false
//
//        print("Запрос на сервер: \(url.absoluteString)")
//
//        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
//            defer { self?.isLoading = false }
//
//            if let error = error {
//                print("Ошибка при получении слайдов: \(error.localizedDescription)")
//                DispatchQueue.main.async {
//                    self?.isError = true
//                    completion(false)
//                }
//                return
//            }
//
//            guard let data = data else {
//                print("Нет данных в ответе")
//                DispatchQueue.main.async {
//                    self?.isError = true
//                    completion(false)
//                }
//                return
//            }
//
//            do {
//                let slides = try JSONDecoder().decode([Slide].self, from: data)
//                DispatchQueue.main.async {
//                    self?.slides = slides
//                    completion(true)
//                }
//            } catch {
//                print("Ошибка декодирования слайдов: \(error.localizedDescription)")
//                DispatchQueue.main.async {
//                    self?.isError = true
//                    completion(false)
//                }
//            }
//        }.resume()
//    }
// }
// import Foundation
// import Combine
//
// class SlideViewModel: ObservableObject {
//    @Published var slides: [Slide]
//    @Published var isLoading = false
//    @Published var isError = false
//    var baseURL: String = BaseURL.alfa + "sliders/"
//
//    init(slides: [Slide] ) {
//            self.slides = slides
//            print("📡 Инициализация SlideViewModel с \(slides.count) слайдами")
//        }
//
//    func fetchSlides(completion: @escaping (Bool) -> Void) {
//        print("📡 Запуск fetchSlides")
//        loadSlidesFromServer(completion: completion)
//    }
//
//
//    private func loadSlidesFromServer(completion: @escaping (Bool) -> Void) {
//        guard let url = URL(string: baseURL) else {
//            print("❌ Неверный URL: \(baseURL)")
//            completion(false)
//            return
//        }
//
//        print("📡 Формируем запрос с URL: \(url)")
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//
//        isLoading = true
//        isError = false
//
//        print("📡 Отправка запроса: \(request)")
//
//        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
//            defer { self?.isLoading = false }
//
//            if let error = error {
//                print("❌ Ошибка запроса: \(error.localizedDescription)")
//                DispatchQueue.main.async {
//                    self?.isError = true
//                    completion(false)
//                }
//                return
//            }
//
//            if let httpResponse = response as? HTTPURLResponse {
//                print("ℹ️ Код ответа: \(httpResponse.statusCode)")
//                print("ℹ️ Заголовки ответа: \(httpResponse.allHeaderFields)")
//            }
//
//            guard let data = data else {
//                print("❌ Ошибка: пустой ответ от сервера")
//                DispatchQueue.main.async {
//                    self?.isError = true
//                    completion(false)
//                }
//                return
//            }
//
//            if let jsonString = String(data: data, encoding: .utf8) {
//                print("✅ Полученные данные: \(jsonString)")
//            } else {
//                print("⚠️ Не удалось декодировать данные в строку")
//            }
//
//            do {
//                let slides = try JSONDecoder().decode([Slide].self, from: data)
//                DispatchQueue.main.async {
//                    self?.slides = slides
//                    print("✅ Загружено \(slides.count) слайдов")
//                    completion(true)
//                }
//            } catch {
//                print("❌ Ошибка декодирования JSON: \(error.localizedDescription)")
//                DispatchQueue.main.async {
//                    self?.isError = true
//                    completion(false)
//                }
//            }
//        }.resume()
//    }
// }
import Foundation

class SlideViewModel: ObservableObject {
    @Published var slides: [Slide]

    private let baseURL = BaseURL.alfa + "sliders/"

    init(slides: [Slide]) {
        self.slides = slides
    }

    func fetchSlides(completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: baseURL) else {
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            if error != nil || data == nil {
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }

            do {
                let slides = try JSONDecoder().decode([Slide].self, from: data!)
                DispatchQueue.main.async {
                    self?.slides = slides
                    completion(true)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }.resume()
    }
}
