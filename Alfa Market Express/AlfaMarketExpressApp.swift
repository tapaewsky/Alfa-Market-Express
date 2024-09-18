//
//  WareHouse1App.swift
//  WareHouse1
//
//  Created by Said Tapaev on 06.07.2024.
//

import SwiftUI

@main
struct AlfaMarketExpress: App {
    @StateObject private var authManager = AuthManager.shared
    @StateObject private var mainViewModel = MainViewModel()
    var body: some Scene {
        WindowGroup {
            Group {
                if authManager.isCheckingAuth {
                    ProgressView()
                } else if authManager.isAuthenticated {
                    ContentView()
                        .preferredColorScheme(.light)
                        .environmentObject(mainViewModel) 
                } else {
                    LoginView()
                        .preferredColorScheme(.light)
                }
            }
            .onAppear {
                authManager.checkAuthentication()
            }
        }
    }
}
