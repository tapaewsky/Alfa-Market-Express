//
//  AuthicantedView.swift
//  AlfaMarketExpress
//
//  Created by Said Tapaev on 24.12.2024.
//

import SwiftUI

struct AuthenticatedView: View {
    @StateObject private var authManager = AuthManager.shared
    @StateObject private var viewModel = MainViewModel()
    @StateObject private var networkMonitor = NetworkMonitor()
    @State private var isLoaded = false

    var body: some View {
        ZStack {
            if isLoaded {
                ContentView()
            } else {
                SplashLogoView()
            }
        }
        .onAppear {
            loadInitialData()
        }
        .onChange(of: networkMonitor.isConnected) { isConnected in
            if isConnected {
                loadInitialData()
            }
        }
    }

    private func loadInitialData() {
        viewModel.productViewModel.fetchProducts { success in
            DispatchQueue.main.async {
                if success {
                    isLoaded = true
                } else {
                    print("Ошибка загрузки продуктов")
                }
            }
        }
    }
}
