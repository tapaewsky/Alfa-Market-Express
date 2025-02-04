//
//  ProfileView.swift
//  AlfaMarketExpress
//
//  Created by Said Tapaev on 24.12.2024.
//

import SwiftUI

struct ProfileView: View {
    @State private var selectedTab: Int = 0
    @ObservedObject var viewModel: MainViewModel
    @StateObject var networkMonitor: NetworkMonitor = NetworkMonitor()
    @StateObject var authManager: AuthManager = .shared
    
    
    var body: some View {
        VStack(alignment: .leading) {
            if networkMonitor.isConnected {
                if (authManager.accessToken != nil) {
                    ProfileInfo(viewModel: viewModel)
                } else {
                    LoginAndRegistration()
                }
            } else {
                NoInternetView(viewModel: viewModel)
            }
        }
        .padding()
    }
}


struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(viewModel: MainViewModel())
    }
}
