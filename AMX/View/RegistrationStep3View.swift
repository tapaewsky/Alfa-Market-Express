//
//  RegistrationStep3View.swift
//  AMX
//
//  Created by Said Tapaev on 13.01.2025.
//

import SwiftUI

struct RegistrationStep3View: View {
    @State private var verificationCode: String = ""
    
    var onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Шаг 3: Введите код из SMS")
                .font(.title2)
                .bold()
            
            CustomTextFieldRegistration(placeholder: "Код из SMS", text: $verificationCode)
                .keyboardType(.numberPad)
            
            Spacer()
            
            CustomButtonRegistration(title: "Продолжить", action: onNext)
        }
        .padding()
    }
}

struct RegistrationStep3View_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationStep3View(onNext: { })
    }
}
