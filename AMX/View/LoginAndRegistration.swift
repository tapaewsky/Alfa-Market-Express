//
//  LoginAndRegistration.swift
//  AMX
//
//  Created by Said Tapaev on 13.01.2025.
//

import SwiftUI

struct LoginAndRegistration: View {
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    // Кнопка "Войти"
                    NavigationLink(destination: LoginView()) {
                        Text("Войти")
                            .font(.title)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()

                    // Кнопка "Зарегистрироваться"
                    NavigationLink(destination: RegistrationView()) {
                        Text("Зарегистрироваться")
                            .font(.title)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                }
            }
        }
    }
}

// Превью экрана регистрации и входа
struct LoginAndRegistration_Previews: PreviewProvider {
    static var previews: some View {
        LoginAndRegistration()
    }
}
