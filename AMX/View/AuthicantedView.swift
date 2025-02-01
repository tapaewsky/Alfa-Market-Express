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
    
    var body: some View {
        ContentView()
    }
}

