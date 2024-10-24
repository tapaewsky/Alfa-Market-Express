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
    
   

    // MARK: - Initializer
    init() {
        self.categoryViewModel = CategoryViewModel()
        self.productViewModel = ProductViewModel()
        self.favoritesViewModel = FavoritesViewModel()
        self.cartViewModel = CartViewModel()
        self.profileViewModel = ProfileViewModel()
        self.slideViewModel = SlideViewModel()
        self.searchViewModel = SearchViewModel()

        // Инициализация ordersViewModel после создания объекта
        self.ordersViewModel = OrdersViewModel(cartViewModel: self.cartViewModel)
    }

    // MARK: - Reset State
//    func resetState(for tab: Int) {
//        print("Сброс состояния для вкладки: \(tab)")
//        switch tab {
//        case 0:
//            productViewModel.reset()
//        case 1:
//            categoryViewModel.reset()
//        case 2:
//            cartViewModel.reset()
//        case 3:
//            favoritesViewModel.reset()
//        case 4:
//            profileViewModel.reset()
//        default:
//            break
//        }
//    }
}
