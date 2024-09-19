//
//  MainViewModel.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 09.09.2024.
//
import SwiftUI
import Combine

class MainViewModel: ObservableObject {
    @Published var categoryViewModel = CategoryViewModel()
    @Published var productViewModel = ProductViewModel()
    @Published var cartViewModel = CartViewModel()
    @Published var favoritesViewModel = FavoritesViewModel()
    
}

