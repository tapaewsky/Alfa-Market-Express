//
//  RegistrationStep2View.swift
//  AMX
//
//  Created by Said Tapaev on 13.01.2025.
//
import SwiftUI

struct PhoneNumberView: View {
    @State private var phoneNumber: String = ""
    @State private var isCodeSent: Bool = false
    @ObservedObject var viewModel: RegistrationVM
    var onNext: (String) -> Void  // Передаем введенный номер телефона при переходе на следующий шаг

    var body: some View {
        VStack(spacing: 20) {
            Text("Шаг 1: Введите номер телефона")
                .font(.title2)
                .bold()
            
            TextField("Введите номер телефона", text: $phoneNumber)
                .keyboardType(.phonePad)
                .padding()
                .border(Color.gray, width: 1)
            
            Button(action: {
                // Отправка кода
                viewModel.sendCode(phoneNumber: phoneNumber) { success, message in
                    if success {
                        print(message ?? "Код успешно отправлен")
                        isCodeSent = true
                        onNext(phoneNumber) // Передаем телефон в родительский компонент
                    } else {
                        print("Ошибка отправки кода: \(message ?? "Неизвестная ошибка")")
                    }
                }
            }) {
                Text("Отправить код")
                    .bold()
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .disabled(phoneNumber.isEmpty) // Деактивируем кнопку, если номер пустой
            
            if isCodeSent {
                Text("Код отправлен на ваш номер!")
                    .foregroundColor(.green)
            }
        }
        .padding()
    }
}
