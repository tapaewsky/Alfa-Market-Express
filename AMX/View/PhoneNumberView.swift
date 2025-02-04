//
//  RegistrationStep2View.swift
//  AMX
//
//  Created by Said Tapaev on 13.01.2025.
//

import SwiftUI

struct PhoneNumberView: View {
    @State private var phoneNumber: String = "+7 "
    @State private var isCodeSent: Bool = false
    @State private var isChecked: Bool = false
    @StateObject var viewModel: RegistrationVM
    
    @Environment(\.dismiss) var dismiss
    
    private func formattedPhoneNumber(_ number: String) -> String {
        let digits = number.filter { $0.isNumber }
        
        guard digits.hasPrefix("7") else { return "+7 " }
        
        let numbersOnly = digits.dropFirst()
        var formatted = "+7"
        
        for (index, char) in numbersOnly.prefix(10).enumerated() {
            if index == 0 { formatted.append(" (") }
            if index == 3 { formatted.append(") ") }
            if index == 6 || index == 8 { formatted.append("-") }
            formatted.append(char)
        }
        
        return formatted
    }
    
    var phoneNumberForServer: String {
        return phoneNumber.filter { $0.isNumber }
    }
    
    private func updateIsChecked() {
        isChecked = phoneNumberForServer.count == 11
    }
    
    private var headerSection: some View {
        VStack {
            ZStack {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.colorGreen)
                            .font(.title3)
                    }
                    Spacer()
                }
                Text("Вход")
                    .font(.title2)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            Divider()
                .background(Color.gray)
                .frame(maxWidth: .infinity)
        }
        .background(Color.white)
    }
    
    private var phoneText: some View {
        HStack {
            Text("Введите номер телефона, чтобы войти")
                .multilineTextAlignment(.leading)
                .font(.title3)
                .foregroundColor(.black)
                .bold()
                .padding(.trailing, 110)
        }
    }
    
    private var phoneNumberTextField: some View {
        TextField("+7 (XXX) XXX-XX-XX", text: $phoneNumber)
            .keyboardType(.phonePad)
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).stroke(Color.colorGreen, lineWidth: 1))
            .onChange(of: phoneNumber) { _ in
                phoneNumber = formattedPhoneNumber(phoneNumber)
                updateIsChecked()
            }
    }
    
    private var getCodeButton: some View {
        Button(action: {
            if phoneNumberForServer.count == 11 {
                viewModel.sendCode(phoneNumber: phoneNumberForServer) { success, message in
                    if success {
                        isCodeSent = true
                    }
                }
            }
        }) {
            Text("Получить код")
                .bold()
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(phoneNumberForServer.count == 11 && isChecked ? Color.colorGreen : Color.gray)
                .cornerRadius(10)
        }
        .disabled(phoneNumberForServer.count != 11 || !isChecked)
    }
    
    private var navigationLink: some View {
        NavigationLink(
            destination: VerificationCodeView(viewModel: MainViewModel(), phoneNumber: phoneNumberForServer),
            isActive: $isCodeSent
        ) {
            EmptyView()
        }
        .navigationBarHidden(true)

    }
    
    var body: some View {
        VStack(spacing: 20) {
            headerSection
            phoneText
            phoneNumberTextField
            Spacer()
            getCodeButton
            navigationLink
        }
        .padding()
        .navigationBarBackButtonHidden(true)
    }
}

struct PhoneNumberView_Previews: PreviewProvider {
    static var previews: some View {
        PhoneNumberView(viewModel: RegistrationVM())
    }
}
