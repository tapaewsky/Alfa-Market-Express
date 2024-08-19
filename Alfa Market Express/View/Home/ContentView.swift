//
//  ContentView.swift
//  WareHouse1
//
//  Created by Said Tapaev on 06.07.2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ProductViewModel()
    @StateObject private var profileViewModel = ProfileViewModel()
    
    var body: some View {
        TabView {
            // Главная страница
            HomeView(viewModel: viewModel, profileViewModel: profileViewModel)
                .tabItem {
                   Image(systemName: "house")
                }
            
            // Каталог
            NavigationView {
                CatalogView(viewModel: viewModel, profileViewModel: profileViewModel)
            }
            .tabItem {
                 Image(systemName: "list.dash")
            }
            
            // Корзина
            NavigationView {
                CartView(viewModel: viewModel, profileViewModel: profileViewModel)
            }
            .tabItem {
                 Image(systemName: "cart")
            }
            
            // Избранное
            NavigationView {
                FavoritesView(viewModel: viewModel, profileViewModel: profileViewModel)
            }
            .tabItem {
                 Image(systemName: "heart")
            }
            
            // Профиль
            NavigationView {
                ProfileView(viewModel: viewModel, profileViewModel: profileViewModel)
            }
            .tabItem {
                 Image(systemName: "person.circle")
            }
            
            
        }
//        .onAppear {
//
//            viewModel.fetchProducts()
//            viewModel.fetchCategories()
//        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
