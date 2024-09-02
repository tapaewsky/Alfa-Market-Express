//
//  NetworkManager.swift
//  WareHouse1
//
//  Created by Said Tapaev on 06.07.2024.
//

import Foundation
import Combine

enum NetworkError: Error {
    case invalidURL
    case noData
    case unableToDecode
}

class NetworkManager: ObservableObject {
    // выпилить из менеджера
    private let decoder = JSONDecoder()
    
    
    func fetchProducts(
        from urlString: String,
        completion: @escaping (Result<[Product], NetworkError>) -> Void
    ) {
        guard let url = URL(string: urlString) else { return completion(.failure(.invalidURL)) }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            // обработать ошибки и написать какой нибудь дженерик слой нетворкинга для переиспользования кода
            if let data = data {
                if let products = try? self?.decoder.decode([Product].self, from: data) {
                    completion(.success(products))
                }
            }
        }.resume()
    }
    
    
}
