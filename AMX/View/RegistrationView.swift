//
//  RegistrationView.swift
//  AMX
//
//  Created by Said Tapaev on 13.01.2025.
//

import SwiftUI

struct RegistrationView: View {
    @State private var currentStep: RegistrationStep = .step1
    @State private var phone: String = ""  // Обновляем номер телефона на уровне RegistrationView
    @State private var isAccountExists: Bool = false // Флаг для проверки аккаунта
    
    @StateObject private var profileViewModel = ProfileViewModel()
    @StateObject private var registrationViewModel = RegistrationVM() // Создаем отдельную модель для регистрации
    
    var body: some View {
        VStack {
            switch currentStep {
            case .step1:
                PhoneNumberView(viewModel: registrationViewModel, onNext: { phoneNumber in
                    // Обновляем номер телефона
                    self.phone = phoneNumber
                    // Проверяем, что телефон не пустой перед переходом
                    if !phone.isEmpty {
                        currentStep = .step2
                    } else {
                        print("Телефон не может быть пустым!")
                    }
                })
            case .step2:
                if !phone.isEmpty {
                    VerificationCodeView(viewModel: registrationViewModel, phoneNumber: phone, onVerified: {
                    })
                }
            case .step3:
                    RegistrationInfo(viewModel: ProfileViewModel(), onNext: {
                        profileViewModel.updateProfile { success in
                            if success {
                                currentStep = .step4
                            } else {
                                print("Ошибка обновления профиля")
                            }
                        }
                    })
            case .step4:
                ProfileView(viewModel: MainViewModel())
            }
        }
//        .onAppear {
//            profileViewModel.fetchUserProfile { success in
//                if success {
//                    self.isAccountExists = true
//                    self.currentStep = .step4
//                } else {
//                    self.isAccountExists = false
//                    self.currentStep = .step3
//                }
//            }
//        }
        .animation(.easeInOut, value: currentStep)
    }
}

enum RegistrationStep {
    case step1, step2, step3, step4
}

struct RegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationView()
    }
}
