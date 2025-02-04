//
//  RegistrationStep3View.swift
//  AMX
//
//  Created by Said Tapaev on 13.01.2025.
//

import SwiftUI

struct RegistrationInfo: View {
    @StateObject var viewModel: ProfileViewModel
    @State private var showError = false
    @State private var isActive = false
    @State private var isLoading = false // Показываем загрузку

    var body: some View {
        VStack(spacing: 20) {
            Text("Информация о регистрации")
                .font(.title2)
                .bold()

            CustomTextFieldRegistration(placeholder: "Имя", text: $viewModel.userProfile.firstName)
            CustomTextFieldRegistration(placeholder: "Фамилия", text: $viewModel.userProfile.lastName)
            CustomTextFieldRegistration(placeholder: "Адрес", text: $viewModel.userProfile.storeAddress)

            if showError {
                Text("Пожалуйста, заполните все поля.")
                    .font(.subheadline)
                    .foregroundColor(.red)
            }

            if isLoading {
                ProgressView()
            }

            Spacer()

            NavigationLink(
                destination: ProfileView(viewModel: MainViewModel())
                    .navigationBarBackButtonHidden(true),
                isActive: $isActive
            ) {
                CustomButtonRegistration(title: "Продолжить", action: {
                    if isAllFieldsFilled() {
                        showError = false
                        isLoading = true

                        viewModel.updateProfile { success in
                            DispatchQueue.main.async {
                                isLoading = false
                                if success {
                                    isActive = true
                                } else {
                                    showError = true
                                }
                            }
                        }
                    } else {
                        showError = true
                    }
                })
            }
        }
        .padding()
    }

    private func isAllFieldsFilled() -> Bool {
        return !viewModel.userProfile.firstName.isEmpty &&
               !viewModel.userProfile.lastName.isEmpty &&
               !viewModel.userProfile.storeAddress.isEmpty
    }
}
