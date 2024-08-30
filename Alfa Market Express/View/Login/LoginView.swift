//
//  Log In.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 22.08.2024.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var profileViewModel = ProfileViewModel()
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var showPassword: Bool = false
    @State private var isLoggingIn: Bool = false
    @State private var navigateToContentView: Bool = false
    @State private var loginFailed: Bool = false
    private let customGreen = Color(red: 38 / 255, green: 115 / 255, blue: 21 / 255)

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [customGreen, Color.white]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                Spacer()

                Text("Добро пожаловать!")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.bottom, 10)

                

                VStack(spacing: 20) {
                    TextField("Имя пользователя", text: $username)
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(30)
                        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)

                    HStack {
                        ZStack {
                            SecureField("Пароль", text: $password)
                                .padding()
                                .opacity(showPassword ? 0 : 1)

                            TextField("Пароль", text: $password)
                                .padding()
                                .opacity(showPassword ? 1 : 0)
                        }
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(30)
                        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)

                        Button(action: {
                            showPassword.toggle()
                        }) {
                            Image(systemName: showPassword ? "eye.slash" : "eye")
                                .foregroundColor(.gray)
                                .padding(.trailing, 10)
                        }
                    }

                    if loginFailed {
                        Text("Неправильное имя пользователя или пароль")
                            .foregroundColor(.red)
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .padding(.top, 5)
                    }

                    Button(action: {
                        guard !isLoggingIn else {
                            print("Запрос уже выполняется, кнопка нажата повторно") 
                            return
                        }
                        
                        print("Нажата кнопка Войти")
                        isLoggingIn = true
                        print("Начата аутентификация...")

                        profileViewModel.authenticateUser(username: username, password: password) { success in
                            isLoggingIn = false
                            if success {
                                print("Аутентификация успешна, переходим на ContentView")
                                navigateToContentView = true
                            } else {
                                print("Аутентификация не удалась, неправильное имя пользователя или пароль")
                                loginFailed = true
                            }
                        }
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 30)
                                .frame(height: 50)
                                .foregroundColor(customGreen)
                                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)

                            Text("Войти")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding()

                Spacer()
            }
        }
        .fullScreenCover(isPresented: $navigateToContentView) {
            ContentView()
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
