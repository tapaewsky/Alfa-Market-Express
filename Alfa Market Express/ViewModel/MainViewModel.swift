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
    @Published var ordersViewModel: OrdersViewModel?
    @Published var authManager = AuthManager.shared
    @Published var slideViewModel: SlideViewModel
    @Published var searchViewModel: SearchViewModel
    
    init() {
        self.categoryViewModel = CategoryViewModel()
        self.productViewModel = ProductViewModel()
        self.favoritesViewModel = FavoritesViewModel()
        self.cartViewModel = CartViewModel()
        self.profileViewModel = ProfileViewModel()
        self.slideViewModel = SlideViewModel()
        self.searchViewModel = SearchViewModel()
        self.ordersViewModel = OrdersViewModel(cartViewModel: self.cartViewModel)
    }
}
