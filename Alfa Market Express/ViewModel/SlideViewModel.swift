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
//        fetchSlides()
    }
    
    func fetchSlides() {
        print("Запрос продуктов из SlidesViewModel")
        guard let accessToken = authManager.accessToken else {
            print("Access token not found.")
            return
        }
        
        guard let url = URL(string: baseURL) else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("Error fetching slides: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("No data in response")
                return
            }

            do {
                let slides = try JSONDecoder().decode([Slide].self, from: data)
                DispatchQueue.main.async {
                    self?.slides = slides
                }
            } catch {
                print("Error decoding slides: \(error.localizedDescription)")
            }
        }.resume()
    }
}
