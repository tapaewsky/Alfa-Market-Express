//
//  RegistrationStep3View.swift
//  AMX
//
//  Created by Said Tapaev on 13.01.2025.
//

import SwiftUI

struct RegistrationInfo: View {
    @ObservedObject var viewModel: ProfileViewModel
    var onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Шаг 3: Дополнительные данные")
                .font(.title2)
                .bold()
            
            CustomTextFieldRegistration(placeholder: "Имя", text: $viewModel.userProfile.firstName)
            CustomTextFieldRegistration(placeholder: "Фамилия", text: $viewModel.userProfile.lastName)
            CustomTextFieldRegistration(placeholder: "Адрес", text: $viewModel.userProfile.storeAddress)
            
            Spacer()
            
            CustomButtonRegistration(title: "Продолжить", action: {
                // Убедитесь, что все обязательные данные заполнены, прежде чем продолжить
                if !viewModel.userProfile.firstName.isEmpty && !viewModel.userProfile.lastName.isEmpty && !viewModel.userProfile.storeAddress.isEmpty {
                    onNext() // Переход на профиль
                } else {
                    print("Пожалуйста, заполните все поля.")
                }
            })
        }
        .padding()
    }
}
