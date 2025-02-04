//
//  CustomModifier.swift
//  AMX
//
//  Created by Said Tapaev on 13.01.2025.
//

import SwiftUI

struct CustomTextFieldRegistration: View {
    var placeholder: String
    @Binding var text: String
    
    var body: some View {
        TextField(placeholder, text: $text)
            .modifier(CustomTextFieldModifierRegistration())
    }
}

struct CustomButtonRegistration: View {
    var title: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color("colorGreen"))
                .foregroundColor(.white)
                .cornerRadius(10)
        }
    }
}

struct CustomTextFieldModifierRegistration: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color("colorGreen")))
    }
}


