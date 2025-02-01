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
    
    // Флаг, проверяющий, зарегистрирован ли пользователь
    @State private var isRegistered: Bool = false

    var body: some View {
        VStack(alignment: .leading) {
            if networkMonitor.isConnected {
                // Проверяем, зарегистрирован ли пользователь
                if isRegistered {
                    ProfileInfo(viewModel: viewModel)  // Показать информацию профиля, если зарегистрирован
                } else {
                    LoginAndRegistration()  // Показать экран логина/регистрации, если не зарегистрирован
                }
            } else {
                NoInternetView(viewModel: viewModel)
            }
        }
        .onAppear {
            // Проверка, зарегистрирован ли пользователь
            checkRegistrationStatus()
        }
        .padding()
    }

    // Метод для проверки, зарегистрирован ли пользователь
    private func checkRegistrationStatus() {
        // Логика для проверки статуса регистрации
        // Например, может быть запрос к бэкенду или локальная проверка
        isRegistered = AuthManager.shared.isAuthenticated
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(viewModel: MainViewModel())
    }
}
