//
//  RegistrationStep2View.swift
//  AMX
//
//  Created by Said Tapaev on 13.01.2025.
//


import SwiftUI

struct RegistrationStep2View: View {
    @State private var phoneNumber: String = "+7"
    
    var onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Шаг 2: Введите номер телефона")
                .font(.title2)
                .bold()
            
            CustomTextFieldRegistration(placeholder: "Номер телефона", text: $phoneNumber)
                .keyboardType(.phonePad)
            
            Spacer()
            
            CustomButtonRegistration(title: "Отправить SMS", action: onNext)
        }
        .padding()
    }
}
struct RegistrationStep2View_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationStep2View(onNext: { })
    }
}
