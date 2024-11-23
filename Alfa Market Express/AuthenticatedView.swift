//
//  AuthenticatedView.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 25.09.2024.
//

import SwiftUI

struct AuthenticatedView: View {
    @StateObject private var authManager = AuthManager.shared
    @StateObject private var viewModel = MainViewModel()
    
    var body: some View {
        Group {
            if authManager.isCheckingAuth {
                SplashLogoView()
            } else if authManager.isAuthenticated {
                ContentView()
            } else {
                LoginView(viewModel: viewModel)
            }
        }
    }
}

struct SplashLogoView: View {
    var body: some View {
        ZStack {
            Color.colorGreen
                .edgesIgnoringSafeArea(.all)
            GeometryReader { geometry in
                let logoSize: CGFloat = 250
                Image("whiteLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: logoSize, height: logoSize)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2 - 110)
            }
        }
    }
}
