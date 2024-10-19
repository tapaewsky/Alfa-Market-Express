//
//  ProductViewModel.swift
//  WareHouse1
//
//  Created by Said Tapaev on 06.07.2024.
//
import Combine
import Foundation
import SwiftUI

class ProductViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var isLoading = false
    @Published var isError = false
    @Published var searchText: String = ""

    private let networkMonitor = NetworkMonitor()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Base URL
    private let baseURL = "http://95.174.90.162:60/api/products/"

    // MARK: - Initialization
//    init() {
//        fetchData()
//    }

//    // MARK: - Load Products
//    func loadProductsIfNeeded() {
//        if products.isEmpty {
//            fetchData()
//        }
//    }

    // MARK: - Data Fetching
    func fetchProducts(completion: @escaping (Bool) -> Void) {
            guard let url = URL(string: baseURL) else {
                print("Неверный URL")
                completion(false)
                return
            }

            var request = URLRequest(url: url)
           

            isLoading = true
            isError = false

            URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                defer { self?.isLoading = false }

                if let error = error {
                    print("Ошибка при получении продуктов: \(error.localizedDescription)")
                    self?.isError = true
                    completion(false)
                    return
                }

                guard let data = data else {
                    print("Нет данных в ответе")
                    self?.isError = true
                    completion(false)
                    return
                }

                do {
                    let products = try JSONDecoder().decode([Product].self, from: data)
                    DispatchQueue.main.async {
                        self?.products = products
                        completion(true)
                    }
                } catch {
                    print("Ошибка декодирования продуктов: \(error.localizedDescription)")
                    self?.isError = true
                    completion(false)
                }
            }.resume()
        }
    


    func searchProducts(query: String) {
        guard !query.isEmpty else {
            return
        }

        let searchUrl = "\(baseURL)?search=\(query)"

        guard let encodedUrlString = searchUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encodedUrlString) else {
            print("Invalid search URL")
            return
        }

        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [Product].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Error searching products: \(error.localizedDescription)")
                }
            }, receiveValue: { products in
                self.products = products
            })
            .store(in: &cancellables)
    }

    // MARK: - Filtered Products
    var filteredProducts: [Product] {
        if searchText.isEmpty {
            return products
        } else {
            return products.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
}
