//
//  RegistrationStep4View.swift
//  AMX
//
//  Created by Said Tapaev on 13.01.2025.
//

import SwiftUI

struct RegistrationStep4View: View {
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var showPasswordMismatch: Bool = false
    
    var onComplete: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Шаг 4: Установите пароль")
                .font(.title2)
                .bold()
            
            SecureField("Пароль", text: $password)
                .modifier(CustomTextFieldModifierRegistration())
            
            SecureField("Подтвердите пароль", text: $confirmPassword)
                .modifier(CustomTextFieldModifierRegistration())
            
            if showPasswordMismatch {
                Text("Пароли не совпадают")
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            Spacer()
            
            CustomButtonRegistration(title: "Завершить регистрацию", action: {
                if password == confirmPassword {
                    showPasswordMismatch = false
                    onComplete()
                } else {
                    showPasswordMismatch = true
                }
            })
        }
        .padding()
    }
}

struct RegistrationStep4View_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationStep4View(onComplete: { })
    }
}
