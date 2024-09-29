//
//  MainViewModel.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 09.09.2024.
//
import SwiftUI
import Combine

class MainViewModel: ObservableObject {
    @Published var categoryViewModel: CategoryViewModel
    @Published var productViewModel: ProductViewModel
    @Published var favoritesViewModel: FavoritesViewModel
    @Published var cartViewModel: CartViewModel
    @Published var profileViewModel: ProfileViewModel

    init() {
        favoritesViewModel = FavoritesViewModel()
        categoryViewModel = CategoryViewModel()
        productViewModel = ProductViewModel()
        cartViewModel = CartViewModel(favoritesViewModel: FavoritesViewModel())
        profileViewModel = ProfileViewModel()
    }
}
