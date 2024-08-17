//
//  ProfileView.swift
//  WareHouse1
//
//  Created by Said Tapaev on 06.07.2024.
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject var viewModel: ProductViewModel
    @ObservedObject var profileViewModel: ProfileViewModel
    private let customGreen = Color(red: 38 / 255, green: 115 / 255, blue: 21 / 255)

    var body: some View {
        VStack {
           
            HeaderView(viewModel: viewModel, profileViewModel: profileViewModel, customGreen: customGreen)
                .padding(.top, 0)

            if let url = URL(string: profileViewModel.userProfile.profileImageUrl) {
                AsyncImage(url: url) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                } placeholder: {
                    ProgressView()
                }
            }

            Form {
                Section(header: Text("Информация о пользователе")) {
                    TextField("Имя пользователя", text: $profileViewModel.userProfile.username)
                    TextField("Имя", text: $profileViewModel.userProfile.firstName)
                    TextField("Фамилия", text: $profileViewModel.userProfile.lastName)
                }

                Section(header: Text("Информация о магазине")) {
                    TextField("Название магазина", text: $profileViewModel.userProfile.storeName)
                    TextField("Адрес магазина", text: $profileViewModel.userProfile.storeAddress)
                    TextField("Номер телефона магазина", text: $profileViewModel.userProfile.storePhoneNumber)
                    TextField("Имя менеджера", text: $profileViewModel.userProfile.managerName)
                    TextField("Номер телефона менеджера", text: $profileViewModel.userProfile.managerPhoneNumber)
                    TextField("Код магазина", text: $profileViewModel.userProfile.storeCode)
                    TextField("Непогашенный долг", value: $profileViewModel.userProfile.outstandingDebt, format: .currency(code: "RUB"))
                }
            }

            Button(action: {
                print("Изменения сохранены")
            }) {
                Text("Сохранить изменения")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
        }
        
    }
}


