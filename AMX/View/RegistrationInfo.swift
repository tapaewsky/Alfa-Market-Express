//
//  RegistrationStep3View.swift
//  AMX
//
//  Created by Said Tapaev on 13.01.2025.
//

import SwiftUI

struct RegistrationInfo: View {
    @StateObject var viewModel = MainViewModel()
    @State private var showError = false
    @State private var isActive = false
    @State private var isLoading = false

    var body: some View {
        VStack/*(spacing: 20)*/ {
            Text("Вход")
                .font(.title3)
                .bold()
                .frame(maxWidth: .infinity, alignment: .center)
            
            Divider()
                .frame(width: 500)
                .background(Color.gray)
                .opacity(0.4)
            
            Text("Данные клиента")
                .font(.title3)
                .bold()
            
            
            CustomTextFieldRegistration(placeholder: "Имя", text: $viewModel.profileViewModel.userProfile.firstName)
            CustomTextFieldRegistration(placeholder: "Фамилия", text: $viewModel.profileViewModel.userProfile.lastName)
            CustomTextFieldRegistration(placeholder: "Адрес", text: $viewModel.profileViewModel.userProfile.storeAddress)
            
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
                        
                        viewModel.profileViewModel.updateProfile { success in
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
        .navigationBarBackButtonHidden(true)
        .padding()
    }
    
    private func isAllFieldsFilled() -> Bool {
        !viewModel.profileViewModel.userProfile.firstName.isEmpty &&
        !viewModel.profileViewModel.userProfile.lastName.isEmpty &&
        !viewModel.profileViewModel.userProfile.storeAddress.isEmpty
    }
}

struct RegistrationInfo_Preview: PreviewProvider {
    static var previews: some View {
        RegistrationInfo()
    }
}
