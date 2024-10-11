//
//  EditProfile.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 25.09.2024.
//
import SwiftUI


struct EditProfile: View {
    @ObservedObject var viewModel: MainViewModel
    
    var body: some View {
        VStack {
            navBar
            formFields
            saveButton
        }
        .padding(.horizontal, 30)
    }
    
    private var navBar: some View {
        Text("Редактировать профиль")
            .font(.title2)
            .bold()
            .foregroundColor(.black)
            .padding(.bottom, 20)
    }
    
    private var formFields: some View {
        VStack(spacing: 10) {
            editTextField(placeholder: viewModel.profileViewModel.userProfile.username, text: $viewModel.profileViewModel.userProfile.username)
            editTextField(placeholder: viewModel.profileViewModel.userProfile.storeName, text: $viewModel.profileViewModel.userProfile.storeName)
            editTextField(placeholder: viewModel.profileViewModel.userProfile.storeAddress, text: $viewModel.profileViewModel.userProfile.storeAddress)
            editTextField(placeholder: viewModel.profileViewModel.userProfile.storePhoneNumber, text: $viewModel.profileViewModel.userProfile.storePhoneNumber)
//            editTextField(placeholder: "Пароль", text: $viewModel.profileViewModel.userProfile.password)
        }
    }
    
    private func editTextField(placeholder: String, text: Binding<String>) -> some View {
        TextField(placeholder, text: text)
            .padding()
            .background(RoundedRectangle(cornerRadius: 15).stroke(.colorGreen, lineWidth: 1))
    }
    
    private var saveButton: some View {
        Button(action: {
            viewModel.profileViewModel.saveProfile { success in
                if success {
                    print("Профиль успешно сохранен")
                } else {
                    print("Ошибка при сохранении профиля")
                }
            }
        }) {
            Text("Сохранить")
                .bold()
                .frame(maxWidth: .infinity)
                .padding()
                .background(.colorGreen)
                .foregroundColor(.white)
                .cornerRadius(15)
        }
        .padding(.top, 20)
    }
}
