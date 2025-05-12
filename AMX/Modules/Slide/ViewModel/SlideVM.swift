//
//  SlideVM.swift
//  AlfaMarketExpress
//
//  Created by Said Tapaev on 24.12.2024.
//

import Foundation
import Combine

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
