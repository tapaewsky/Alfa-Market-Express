//
//  EditProfile.swift
//  AlfaMarketExpress
//
//  Created by Said Tapaev on 24.12.2024.
//

import Kingfisher
import SwiftUI

struct EditProfile: View {
    @ObservedObject var viewModel: MainViewModel
    @State private var showImagePicker: Bool = false
    @Environment(\.presentationMode) var presentationMode
    @State private var showAlert = false
    @State private var showProfile = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack {
                navBar
                imagePickerButton
                    .padding(.bottom)
                formFields
                saveButton
                deleteProfileButton
            }
            .padding()
        }
        .navigationBarItems(leading: CustomBackButton {
            self.presentationMode.wrappedValue.dismiss()
        })
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $viewModel.profileViewModel.selectedImage)
        }
    }

    private var navBar: some View {
        Text("Редактировать профиль")
            .font(.title2)
            .bold()
            .foregroundColor(.black)
    }

    private var imagePickerButton: some View {
        VStack {
            if let selectedImage = viewModel.profileViewModel.selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .cornerRadius(20)
                    .frame(maxWidth: .infinity)
            } else {
                if let storeImageUrl = viewModel.profileViewModel.userProfile.storeImageUrl,
                   let url = URL(string: storeImageUrl)
                {
                    KFImage(url)
                        .placeholder { ProgressView() }
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .cornerRadius(20)
                        .frame(maxWidth: .infinity)
                } else {
                    Image("placeholderStoreImage")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .cornerRadius(20)
                        .frame(maxWidth: .infinity)
                }
            }

            Button(action: { showImagePicker = true }) {
                Text("Изменить фото магазина")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .foregroundColor(Color("colorGreen"))
            }
        }
    }

    private var formFields: some View {
        VStack {
            editTextField(placeholder: viewModel.profileViewModel.userProfile.firstName, text: $viewModel.profileViewModel.userProfile.firstName)
            editTextField(placeholder: viewModel.profileViewModel.userProfile.lastName, text: $viewModel.profileViewModel.userProfile.lastName)
            editTextField(placeholder: viewModel.profileViewModel.userProfile.storeAddress, text: $viewModel.profileViewModel.userProfile.storeAddress)
        }
    }

    private func editTextField(placeholder: String, text: Binding<String>) -> some View {
        TextField(placeholder, text: text)
            .padding()
            .background(RoundedRectangle(cornerRadius: 15).stroke(Color("colorGreen"), lineWidth: 1))
    }

    private var saveButton: some View {
        Button(action: {
            Task {
                // Обеспечиваем, что выполнение сохранения пройдет в главном потоке.
                await viewModel.profileViewModel.updateProfile { success in
                    DispatchQueue.main.async {
                        if success {
                            if self.presentationMode.wrappedValue.isPresented {
                                self.presentationMode.wrappedValue.dismiss()
                            }
                        } else {
                            print("Ошибка при сохранении профиля")
                        }
                    }
                }
            }
        }) {
            Text("Сохранить")
                .bold()
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color("colorGreen"))
                .foregroundColor(.white)
                .cornerRadius(15)
        }
        .padding()
    }

    private var deleteProfileButton: some View {
        VStack {
            Button("Удалить аккаунт") {
                showAlert = true
            }
            .foregroundColor(.red)
            .padding()
            .alert("Вы уверены, что хотите удалить аккаунт?", isPresented: $showAlert) {
                Button("Отмена", role: .cancel) {}
                Button("Удалить", role: .destructive) {
                    // Выполняем удаление профиля сначала
                    viewModel.profileViewModel.deleteProfile { success in
                        if success {
                            self.presentationMode.wrappedValue.dismiss()
                            print("Аккаунт успешно удалён.")
                        } else {
                            print("Ошибка при удалении аккаунта")
                        }
                    }
                }
            } message: {
                Text("Это действие нельзя отменить")
            }
        }
    }
}
