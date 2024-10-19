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
            
            HomeView(viewModel: MainViewModel())
            .tabItem {
                Image(systemName: "house")
            }

            NavigationView {
                CategoryView(viewModel: MainViewModel())
            }
            .tabItem {
                Image(systemName: "list.dash")
            }

            NavigationView {
                CartView(viewModel: MainViewModel())
            }
            .tabItem {
                Image(systemName: "cart")
            }
            
            NavigationView {
                FavoritesView(viewModel: MainViewModel())
            }
            .tabItem {
                Image(systemName: "heart")
            }

            NavigationView {
                ProfileView(viewModel: MainViewModel())
            }
            .tabItem {
                Image(systemName: "person.circle")
            }
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
