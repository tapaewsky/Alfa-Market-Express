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
    @StateObject var networkMonitor: NetworkMonitor = .init()
    @StateObject var authManager: AuthManager = .shared

    var body: some View {
        VStack(alignment: .leading) {
            if networkMonitor.isConnected {
                if let _ = authManager.accessToken {
                    HStack {
                        Spacer()
                        NavigationLink(destination: EditProfile(viewModel: viewModel)) {
                            ZStack {
                                Image(systemName: "person")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.colorGreen)

                                Image(systemName: "gearshape")
                                    .resizable()
                                    .frame(width: 10, height: 10)
                                    .foregroundColor(.colorGreen)
                                    .offset(x: 15, y: -5)
                            }
                        }
                        .navigationBarHidden(true)
                        .padding(.horizontal)
                    }
                    ProfileInfo(viewModel: viewModel)
                } else {
                    LoginAndRegistration()
                }
            } else {
                NoInternetView(viewModel: viewModel)
            }
        }
        .navigationBarBackButtonHidden(true)
        .padding()
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(viewModel: MainViewModel())
    }
}
