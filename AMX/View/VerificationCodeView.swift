//
//  VerificationCodeView.swift
//  AMX
//
//  Created by Said Tapaev on 02.02.2025.
//

import SwiftUI

struct VerificationCodeView: View {
    @State private var verificationCode: String = ""
    @ObservedObject var viewModel: RegistrationVM
    var phoneNumber: String
    var onVerified: () -> Void
    @State private var errorMessage: String? // Для отображения ошибки
    @State private var isTokenValid: Bool = false // Новый флаг для проверки токена
    @State private var isUserExist: Bool? = nil // Для проверки существующих данных
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Шаг 2: Введите код из SMS")
                .font(.title2)
                .bold()
            
            TextField("Введите код", text: $verificationCode)
                .keyboardType(.numberPad)
                .padding()
                .border(Color.gray, width: 1)
            
            Button(action: {
                // Проверка кода и существования пользователя
                viewModel.verifyCode(phoneNumber: phoneNumber, code: verificationCode) { success, message in
                    if success {
                        print(message ?? "Успешная верификация")
                        isTokenValid = true
                        viewModel.checkUserExistence(phoneNumber: phoneNumber) { userExists, errorMessage in
                            if userExists {
                                isUserExist = true // Устанавливаем флаг для перехода на профиль
                            } else {
                                isUserExist = false // Устанавливаем флаг для перехода на регистрацию
                            }
                        }
                    } else {
                        print(message ?? "Ошибка верификации кода")
                        errorMessage = message
                        isTokenValid = false
                    }
                }
            }) {
                Text("Подтвердить код")
                    .bold()
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .disabled(verificationCode.isEmpty)

            // Отображение ошибки, если код верификации неверен
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.subheadline)
            }

            // Переход на правильное представление в зависимости от isUserExist
            if isTokenValid {
                NavigationLink(destination: destinationView) {
                    EmptyView()
                }
            }
        }
        .padding()
    }

    // Условное представление для перехода
    private var destinationView: some View {
        Group {
            if let userExist = isUserExist {
                if userExist {
                    // Переход в ProfileView
                    ProfileView(viewModel: MainViewModel())
                } else {
                    // Переход в RegistrationInfoView
                    RegistrationInfo(viewModel: ProfileViewModel(), onNext: onVerified)
                }
            } else {
                EmptyView()
            }
        }
    }
}
