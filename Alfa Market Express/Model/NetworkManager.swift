//
//  NetworkManager.swift
//  WareHouse1
//
//  Created by Said Tapaev on 06.07.2024.
//

import Foundation
import Combine

class NetworkManager: ObservableObject {
    @Published var products: [Product] = []
    
    func fetchProducts(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                let decoder = JSONDecoder()
                if let products = try? decoder.decode([Product].self, from: data) {
                    DispatchQueue.main.async {
                        self.products = products
                    }
                }
            }
        }.resume()
    }
}
