//
//  ContentView.swift
//  AlfaMarketExpress
//
//  Created by Said Tapaev on 24.12.2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var authManager = AuthManager.shared
    @StateObject private var viewModel = MainViewModel()
    @State private var selectedTab: Int = 0

    var body: some View {
        VStack {
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
                selectedTab = 0
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("SwitchToProfile"))) { _ in
                selectedTab = 4
            }
        }
    }
}

struct ContentView_Preview: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
