//
//  ContentView.swift
//  WareHouse1
//
//  Created by Said Tapaev on 06.07.2024.
//пака 1

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = MainViewModel()
    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(viewModel: viewModel)
                .tabItem {
                    Image(systemName: "house")
                }
                .tag(0)

            NavigationView {
                CategoryView(viewModel: viewModel)
            }
            .tabItem {
                Image(systemName: "list.dash")
            }
            .tag(1)

            NavigationView {
                CartView(viewModel: viewModel)
            }
            .tabItem {
                Image(systemName: "cart")
            }
            .tag(2)

            NavigationView {
                FavoritesView(viewModel: viewModel)
            }
            .tabItem {
                Image(systemName: "heart")
            }
            .tag(3)

            NavigationView {
                ProfileView(viewModel: viewModel)
            }
            .tabItem {
                Image(systemName: "person.circle")
            }
            .tag(4)
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("SwitchToHome"))) { _ in
            print("Switching to Home tab")
            selectedTab = 0
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
