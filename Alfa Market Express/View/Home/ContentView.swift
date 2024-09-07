//
//  ContentView.swift
//  WareHouse1
//
//  Created by Said Tapaev on 06.07.2024.
//

import SwiftUI

struct ContentView: View {
    
    
    var body: some View {
        TabView {
           
            HomeView(viewModel: ProductViewModel())
                .tabItem {
                   Image(systemName: "house")
                }
            
          
            NavigationView {
                CategoryView(viewModel: ProductViewModel())
            }
            .tabItem {
                 Image(systemName: "list.dash")
            }
            
           
            NavigationView {
                CartView(viewModel: ProductViewModel())
            }
            .tabItem {
                 Image(systemName: "cart")
            }
            
          
            NavigationView {
                FavoritesView(viewModel: ProductViewModel())
            }
            .tabItem {
                 Image(systemName: "heart")
            }
            
      
            NavigationView {
                ProfileView(viewModel: ProfileViewModel())
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
    }
}
