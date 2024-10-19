//
//  EditProfile.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 25.09.2024.
//
import SwiftUI
import Kingfisher

struct EditProfile: View {
    @ObservedObject var viewModel: MainViewModel
    @State private var showImagePicker: Bool = false

    var body: some View {
        ScrollView {
            VStack {
                navBar
                imagePickerButton
                formFields
                saveButton
            }
            .padding(.horizontal, 30)
        }
        .sheet(isPresented: $showImagePicker) {
            // Передаем привязку к selectedImage
            ImagePicker(selectedImage: $viewModel.profileViewModel.selectedImage)
        }
    }

    private var navBar: some View {
        Text("Редактировать профиль")
            .font(.title2)
            .bold()
            .foregroundColor(.black)
            .padding(.bottom, 20)
    }

    private var imagePickerButton: some View {
        VStack {
            if let selectedImage = viewModel.profileViewModel.selectedImage {  // Проверяем, если изображение выбрано
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
            } else {
                // Отображаем фото магазина по умолчанию, если фото не выбрано
                KFImage(URL(string: viewModel.profileViewModel.userProfile.storeImageUrl))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
            }
            
            Button(action: {
                showImagePicker = true  // Открываем ImagePicker
            }) {
                Text("Изменить фото магазина")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(15)
            }
            .padding(.top, 20)
        }
    }

    private var formFields: some View {
        VStack(spacing: 10) {
            editTextField(placeholder: viewModel.profileViewModel.userProfile.firstName, text: $viewModel.profileViewModel.userProfile.firstName)
            editTextField(placeholder: viewModel.profileViewModel.userProfile.lastName, text: $viewModel.profileViewModel.userProfile.lastName)
            editTextField(placeholder: viewModel.profileViewModel.userProfile.storeName, text: $viewModel.profileViewModel.userProfile.storeName)
            editTextField(placeholder: viewModel.profileViewModel.userProfile.storeAddress, text: $viewModel.profileViewModel.userProfile.storeAddress)
            editTextField(placeholder: viewModel.profileViewModel.userProfile.storePhoneNumber, text: $viewModel.profileViewModel.userProfile.storePhoneNumber)
        }
    }

    private func editTextField(placeholder: String, text: Binding<String>) -> some View {
        TextField(placeholder, text: text)
            .padding()
            .background(RoundedRectangle(cornerRadius: 15).stroke(Color.green, lineWidth: 1))
    }

    private var saveButton: some View {
        Button(action: {
            Task {
                viewModel.profileViewModel.updateProfile { success in
                    if success {
                        print("Профиль успешно сохранен")
                    } else {
                        print("Ошибка при сохранении профиля")
                    }
                }
            }
        }) {
            Text("Сохранить")
                .bold()
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(15)
        }
        .padding(.top, 20)
    }
}
