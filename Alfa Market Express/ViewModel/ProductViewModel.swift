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

    private let networkMonitor = NetworkMonitor()
    private let baseURL = "http://95.174.90.162:60/api/products/"


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
  }
