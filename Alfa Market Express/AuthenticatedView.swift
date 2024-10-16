//
//  AuthenticatedView.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 25.09.2024.
//

import SwiftUI

struct AuthenticatedView: View {
    @StateObject private var authManager = AuthManager.shared
    @StateObject private var mainViewModel = MainViewModel()
    
    var body: some View {
        Group {
            if authManager.isCheckingAuth {
                ProgressView()
            } else if authManager.isAuthenticated {
                ContentView()
//                    .preferredColorScheme(.light)
                    .environmentObject(mainViewModel)
            } else {
                LoginView()
//                    .preferredColorScheme(.light)
            }
        }
        .onAppear {
            authManager.checkAuthentication()
        }
    }
}
