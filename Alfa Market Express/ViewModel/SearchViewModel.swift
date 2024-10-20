//
//  SearchViewModel.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 19.10.2024.
//

import Foundation
import Combine

class SearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    private let baseURL: String = "http://95.174.90.162:60/api/products/"
    private var cancellables = Set<AnyCancellable>()
    var products: [Product] = []
    
    func searchProducts(query: String) {
        // Если запрос пустой, не выполняем поиск
        guard !query.isEmpty else {
            self.products = []  // Очищаем список продуктов, если нет запроса
            return
        }

      

        let searchUrl = "\(baseURL)?search=\(query)"
        guard let encodedUrlString = searchUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encodedUrlString) else {
            print("Invalid search URL")
            return
        }

        var request = URLRequest(url: url)
       

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error searching products: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("No data in response")
                return
            }

            do {
                let products = try JSONDecoder().decode([Product].self, from: data)
                DispatchQueue.main.async {
                    self.products = products  // Сохраняем полученные продукты
                }
            } catch {
                print("Error decoding products: \(error.localizedDescription)")
            }
        }.resume()
    }
    var filteredProducts: [Product] {
        if searchText.isEmpty {
            return products
        } else {
            return products.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }

}
