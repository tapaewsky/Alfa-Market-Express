//
//  MainVM.swift
//  AlfaMarketExpress
//
//  Created by Said Tapaev on 24.12.2024.
//

import Combine
import SwiftUI

class MainViewModel: ObservableObject {
    @Published var categoryViewModel: CategoryViewModel
    @Published var productViewModel: ProductViewModel
    @Published var categoryProductViewModel = ProductViewModel()
    @Published var favoritesViewModel: FavoritesViewModel
    @Published var cartViewModel: CartViewModel
    @Published var profileViewModel: ProfileViewModel
    @Published var ordersViewModel: OrdersViewModel?
    @Published var authManager = AuthManager.shared
    @Published var slideViewModel: SlideViewModel
    @Published var searchViewModel: SearchViewModel
    @Published var registrationViewModel: RegistrationVM

    init() {
        categoryViewModel = CategoryViewModel()
        productViewModel = ProductViewModel()
        favoritesViewModel = FavoritesViewModel()
        cartViewModel = CartViewModel()
        profileViewModel = ProfileViewModel()
        slideViewModel = SlideViewModel(slides: [Slide]())
        searchViewModel = SearchViewModel()
        registrationViewModel = RegistrationVM()
        ordersViewModel = OrdersViewModel(cartViewModel: cartViewModel)
    }
}
