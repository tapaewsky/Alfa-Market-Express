//
//  VerificationCodeView.swift
//  AMX
//
//  Created by Said Tapaev on 02.02.2025.
//
//
//import SwiftUI
//
//struct VerificationCodeView: View {
//    @State private var verificationCode: String = ""
//    @StateObject var viewModel: RegistrationVM
//    var phoneNumber: String
//    @State private var errorMessage: String?
//    @State private var isUserExist: Bool? = nil
//    @State private var navigateToProfile = false
//    @State private var navigateToRegistrationInfo = false
//    @FocusState private var isTextFieldFocused: Bool
//    @State private var keyboardHeight: CGFloat = 0
//    @State var authManager: AuthManager = .shared
//    
//    @Environment(\.dismiss) var dismiss
//    
//    private func formattedPhoneNumber(_ number: String) -> String {
//        let digits = number.filter { $0.isNumber }
//        
//        var formatted = "+7 (9"
//        
//        let numbersOnly = digits.dropFirst().dropFirst()
//        
//        for (index, char) in numbersOnly.enumerated() {
//            if index == 2 { formatted.append(") ") }
//            if index == 5 || index == 7 { formatted.append("-") }
//            formatted.append(char)
//        }
//        
//        return formatted
//    }
//    
//    private var header: some View {
//        VStack {
//            ZStack {
//                HStack {
//                    Button(action: { dismiss() }) {
//                        Image(systemName: "chevron.left")
//                            .foregroundColor(.colorGreen)
//                            .font(.title3)
//                    }
//                    Spacer()
//                }
//                Text("Вход")
//                    .font(.title2)
//                    .bold()
//                    .frame(maxWidth: .infinity, alignment: .center)
//            }
//            
//            Divider()
//                .background(Color.gray)
//                .frame(maxWidth: .infinity)
//        }
//        .background(Color.white)
//    }
//    
//    private var verificationCodeCircle: some View {
//        HStack(spacing: 20) {
//            ForEach(0..<6, id: \.self) { index in
//                if index < verificationCode.count {
//                    Text(String(verificationCode[verificationCode.index(verificationCode.startIndex, offsetBy: index)]))
//                        .font(.title)
//                        .frame(width: 40, height: 40)
//                        .bold()
//                        .foregroundColor(.black)
//                } else {
//                    Circle()
//                        .fill(Color.gray)
//                        .frame(width: 20, height: 20)
//                }
//            }
//        }
//        .padding()
//    }
//    
//    private var textFieldsSection: some View {
//        VStack(spacing: 8) {
//            Text("Введите код из SMS")
//                .font(.title2)
//                .bold()
//                .frame(maxWidth: .infinity, alignment: .leading)
//            
//            Text("Код был отправлен на этот номер:")
//                .foregroundColor(.gray)
//                .bold()
//                .frame(maxWidth: .infinity, alignment: .leading)
//            
//            HStack {
//                Text(formattedPhoneNumber(phoneNumber))
//                    .fixedSize(horizontal: true, vertical: false)
//                    .font(.title3)
//                    .foregroundColor(.black)
//                    .bold()
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                
//                Spacer()
//                
//                Button("Изменить") {
//                    dismiss()
//                }
//                .frame(maxWidth: .infinity, alignment: .trailing)
//                .bold()
//                .foregroundColor(.colorGreen)
//            }
//        }
//    }
//    
//    private var errorMessageView: some View {
//        Group {
//            if let errorMessage = errorMessage {
//                Text(errorMessage)
//                    .foregroundColor(.red)
//                    .font(.subheadline)
//            }
//        }
//    }
//    
//    var body: some View {
//        VStack {
//            header
//            
//            Spacer()
//            
//            textFieldsSection
//            
//            verificationCodeCircle
//            
//            TextField("", text: $verificationCode)
//                .keyboardType(.numberPad)
//                .opacity(0)
//                .frame(width: 1, height: 1)
//                .focused($isTextFieldFocused)
//                .onChange(of: verificationCode) { newValue in
//                    if newValue.count == 6 {
//                        verifyCode()
//                        hideKeyboard()
//                    }
//                }
//            
//            errorMessageView
//            
//            NavigationLink(
//                destination: ProfileView(viewModel: MainViewModel()),
//                isActive: $navigateToProfile
//            ) {
//                EmptyView()
//            }
//            .navigationBarBackButtonHidden(true)
//            
//            NavigationLink(
//                destination: RegistrationInfo(viewModel: ProfileViewModel()),
//                isActive: $navigateToRegistrationInfo
//            ) {
//                EmptyView()
//            }
//        }
//        .padding()
//        .onAppear {
//            isTextFieldFocused = true
//            NotificationCenter.default.addObserver(
//                forName: UIResponder.keyboardWillShowNotification,
//                object: nil,
//                queue: .main) { notification in
//                    if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
//                        keyboardHeight = keyboardFrame.height / 2
//                    }
//                }
//            NotificationCenter.default.addObserver(
//                forName: UIResponder.keyboardWillHideNotification,
//                object: nil,
//                queue: .main) { _ in
//                    keyboardHeight = 0
//                }
//        }
//        .navigationBarBackButtonHidden(true)
//        .padding(.bottom, keyboardHeight)
//    }
//    
//    private func verifyCode() {
//        viewModel.verifyCode(phoneNumber: phoneNumber, code: verificationCode) { success, message in
//            if success {
//                authManager.accessToken
//            } else {
//                errorMessage = "Неверный код, повторите попытку."
//                isTextFieldFocused = true
//            }
//        }
//    }
//}
//
//extension View {
//    func hideKeyboard() {
//        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
//    }
//}
//
//struct VerificationCodeView_Previews: PreviewProvider {
//    static var previews: some View {
//        VerificationCodeView(viewModel: RegistrationVM(), phoneNumber: "79123456789")
//    }
//}
import SwiftUI
import Combine

struct VerificationCodeView: View {
    @State private var verificationCode: String = ""
    @StateObject var viewModel = MainViewModel()
    var phoneNumber: String
    @State private var errorMessage: String?
    @State private var navigateToProfile = false
    @State private var navigateToRegistrationInfo = false
    @State private var navigateToHome = false
    @FocusState private var isTextFieldFocused: Bool
    @State private var keyboardHeight: CGFloat = 0
    @State private var cancellables = Set<AnyCancellable>()
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            header
            
            Spacer()
            
            textFieldsSection
            
            verificationCodeCircle
            
            TextField("", text: $verificationCode)
                .keyboardType(.numberPad)
                .opacity(0)
                .frame(width: 1, height: 1)
                .focused($isTextFieldFocused)
                .onChange(of: verificationCode) { newValue in
                    if newValue.count == 6 {
                        verifyCode()
                        hideKeyboard()
                    }
                }
            
            errorMessageView
        }
        NavigationLink(destination: ProfileView(viewModel: viewModel), isActive: $navigateToProfile) {
            Text("")
        }
        .navigationBarHidden(true)

        .navigationBarBackButtonHidden(true)
        
        NavigationLink(destination: RegistrationInfo(viewModel: viewModel), isActive: $navigateToRegistrationInfo) {
            Text("")
        }
        .navigationBarHidden(true)

        
        .onAppear {
            isTextFieldFocused = true
            setupKeyboardNotifications()
            setupProfileFetchCallback()
        }
        .onDisappear {
            removeKeyboardNotifications()
            viewModel.profileViewModel.onProfileFetched = nil
        }
        .navigationBarBackButtonHidden(true)
        .padding(.bottom, keyboardHeight)
    }
    
    private func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: .main) { notification in
                if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    keyboardHeight = keyboardFrame.height / 2
                }
        }
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main) { _ in
                keyboardHeight = 0
        }
    }
    
    private func removeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func formattedPhoneNumber(_ number: String) -> String {
        let digits = number.filter { $0.isNumber }
        var formatted = "+7 (9"
        let numbersOnly = digits.dropFirst().dropFirst()
        
        for (index, char) in numbersOnly.enumerated() {
            if index == 2 { formatted.append(") ") }
            if index == 5 || index == 7 { formatted.append("-") }
            formatted.append(char)
        }
        return formatted
    }
    
    private var header: some View {
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
    
    private var verificationCodeCircle: some View {
        HStack(spacing: 20) {
            ForEach(0..<6, id: \.self) { index in
                if index < verificationCode.count {
                    Text(String(verificationCode[verificationCode.index(verificationCode.startIndex, offsetBy: index)]))
                        .font(.title)
                        .frame(width: 40, height: 40)
                        .bold()
                        .foregroundColor(.black)
                } else {
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 20, height: 20)
                }
            }
        }
        .padding()
    }
    
    private var textFieldsSection: some View {
        VStack(spacing: 8) {
            Text("Введите код из SMS")
                .font(.title2)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("Код был отправлен на номер:")
                .foregroundColor(.gray)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                Text(formattedPhoneNumber(phoneNumber))
                    .fixedSize(horizontal: true, vertical: false)
                    .font(.title3)
                    .foregroundColor(.black)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                Button("Изменить") {
                    dismiss()
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .bold()
                .foregroundColor(.colorGreen)
            }
        }
    }
    
    private var errorMessageView: some View {
        Group {
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.subheadline)
            }
        }
    }
    
    private func verifyCode() {
        viewModel.registrationViewModel.verifyCode(phoneNumber: phoneNumber, code: verificationCode) { success, message in
            if success {
                self.viewModel.profileViewModel.fetchUserProfile(completion: { _ in })
            } else {
                errorMessage = "Неверный код, повторите попытку."
                isTextFieldFocused = true
            }
        }
    }
    
    private func setupProfileFetchCallback() {
        viewModel.profileViewModel.onProfileFetched = { success in
            self.verifyUserProfileData()
        }
    }

    private func verifyUserProfileData() {
        let userHasRequiredData =
            !viewModel.profileViewModel.userProfile.firstName.isEmpty &&
            !viewModel.profileViewModel.userProfile.lastName.isEmpty &&
            !viewModel.profileViewModel.userProfile.storeAddress.isEmpty

        if userHasRequiredData {
            // Оповещаем через NotificationCenter для перехода на Home
            navigateToProfile = true
        } else {
            // Прямо меняем флаг для навигации в RegistrationInfo
            navigateToRegistrationInfo = true
        }
    }
    

    
    private func handleNavigationNotification(_ notification: Notification) {
        if notification.name == Notification.Name("SwitchToHome") {
            self.navigateToHome = true
        } else if notification.name == Notification.Name("SwitchToRegistrationInfo") {
            self.navigateToRegistrationInfo = true
        }
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct VerificationCodeView_Previews: PreviewProvider {
    static var previews: some View {
        VerificationCodeView(viewModel: MainViewModel(), phoneNumber: "79123456789")
    }
}
