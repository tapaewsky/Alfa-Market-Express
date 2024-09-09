//
//  MainViewModel.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 09.09.2024.
//

import Combine

class MainViewModel: ObservableObject {
    @Published var categoryViewModel = CategoryViewModel()
    @Published var productViewModel = ProductViewModel()
    @Published var cartViewModel = CartViewModel()
    @Published var favoritesViewModel = FavoritesViewModel()
    
    init() {
        // Инициализация и загрузка данных
        loadInitialData()
    }
    
    private func loadInitialData() {
        Task {
            await productViewModel.fetchData { success in
                // обработка успеха или ошибки
            }
        }
    }
}
