//
//  SearchVM.swift
//  AlfaMarketExpress
//
//  Created by Said Tapaev on 24.12.2024.
//

import Foundation
import Combine

class SearchViewModel: ObservableObject {
    @Published var searchText: String = ""
//    private let baseURL: String = "https://alfamarketexpress.ru/api/products/"
    private var cancellables = Set<AnyCancellable>()
    @Published var products: [Product] = []
    var baseURL: String = BaseURL.alfa + "products/"
    
    // Основная функция поиска продуктов
    func searchProducts(query: String, completion: @escaping () -> Void) {
        guard !query.isEmpty else {
            self.products = []
            completion()
            return
        }
        
        let searchUrl = "\(baseURL)?search=\(query)"
        guard let encodedUrlString = searchUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encodedUrlString) else {
            print("Invalid search URL")
            completion()
            return
        }
        
        var request = URLRequest(url: url)
        print("Запрос на сервер: \(url.absoluteString)")
        
        // Выполняем запрос
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error searching products: \(error.localizedDescription)")
                completion()
                return
            }
            
            guard let data = data else {
                print("No data in response")
                completion()
                return
            }
            
            do {
                let productResponse = try JSONDecoder().decode(ProductResponse.self, from: data)
                DispatchQueue.main.async {

                    self.products = productResponse.results
                    completion()
                }
            } catch {
                print("Error decoding products: \(error.localizedDescription)")
                completion()
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
