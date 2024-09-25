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
    @State private var keyboardHeight: CGFloat = 0

    var body: some View {
        VStack {
            Spacer()
            Text("Вход")
                .font(.title2)
                .bold()
                .padding(.bottom, 20)
            Image("blackLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 250, height: 250)
                .padding(.bottom, 40)
            loginForm
            Spacer()
        }
        .background(Color.white)
        .fullScreenCover(isPresented: $navigateToContentView) {
            ContentView()
        }
        .onAppear {
            setupKeyboardObservers()
        }
        .onDisappear {
            removeKeyboardObservers()
        }
    }

    private var loginForm: some View {
        VStack {
            TextField("Имя пользователя", text: $username)
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.colorGreen, lineWidth: 1))

            passwordField

            if loginFailed {
                Text("Неправильное имя пользователя или пароль")
                    .foregroundColor(.red)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .padding(.top, 5)
            }

            loginButton
        }
        .padding(.horizontal)
        .padding(.bottom, keyboardHeight + 50)
    }

    private var passwordField: some View {
        HStack {
            Group {
                if showPassword {
                    TextField("Пароль", text: $password)
                        .padding()
                } else {
                    SecureField("Пароль", text: $password)
                        .padding()
                }
            }
            Button(action: { showPassword.toggle() }) {
                Image(systemName: showPassword ? "eye.slash" : "eye")
                    .foregroundColor(showPassword ? .colorGreen : .gray)
                    .padding()
            }
        }
        .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.colorGreen, lineWidth: 1))
    }

    private var loginButton: some View {
        Button(action: login) {
            Text("Войти")
                .foregroundColor(.white)
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.colorGreen)
                .cornerRadius(15)
        }
    }

    private func login() {
        guard !isLoggingIn else { return }
        isLoggingIn = true
        profileViewModel.authenticateUser(username: username, password: password) { success in
            isLoggingIn = false
            if success {
                navigateToContentView = true
            } else {
                loginFailed = true
            }
        }
    }

    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
            if let keyboardSize = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                keyboardHeight = keyboardSize.cgRectValue.height
            }
        }
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
            keyboardHeight = 0
        }
    }

    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}
