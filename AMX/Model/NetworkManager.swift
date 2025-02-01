//
//  NetworkManager.swift
//  AlfaMarketExpress
//
//  Created by Said Tapaev on 24.12.2024.
//

import Foundation
import Combine

enum NetworkError: Error {
    case invalidURL
    case noData
    case unableToDecode
}

class NetworkManager: ObservableObject {
    private let decoder = JSONDecoder()
    
    func fetchProducts(
        from urlString: String,
        completion: @escaping (Result<[Product], NetworkError>) -> Void
    ) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            return completion(.failure(.invalidURL))
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                print("Failed to fetch data: \(error.localizedDescription)")
                return completion(.failure(.noData))
            }
            
            guard let data = data else {
                print("No data received from server")
                return completion(.failure(.noData))
            }
            
            do {
                let products = try self?.decoder.decode([Product].self, from: data)
                print("Successfully fetched products")
                completion(.success(products ?? []))
            } catch {
                print("Failed to decode products: \(error.localizedDescription)")
                completion(.failure(.unableToDecode))
            }
        }.resume()
    }
}
