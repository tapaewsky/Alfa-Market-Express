//
//  ProfileView.swift
//  WareHouse1
//
//  Created by Said Tapaev on 06.07.2024.
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject var productViewModel: ProductViewModel
    @ObservedObject var viewModel: ProfileViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                // Верхняя часть с изображением магазина
                if let url = URL(string: viewModel.userProfile.storeImageUrl) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                }
                
                // Заголовок и кнопка редактирования
                HStack {
                    Text("Профиль")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Button(action: {
                        viewModel.toggleEditing()
                    }) {
                        Text(viewModel.isEditing ? "Сохранить" : "Редактировать")
                            .fontWeight(.semibold)
                            .padding(8)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding()
                
                // Информация о пользователе
                Form {
                    Section(header: Text("Информация о магазине")) {
                        Text("Название магазина: \(viewModel.userProfile.storeName)")
                        Text("Адрес магазина: \(viewModel.userProfile.storeAddress)")
                        Text("Телефон магазина: \(viewModel.userProfile.storePhoneNumber)")
                        Text("Код магазина: \(viewModel.userProfile.storeCode)")
                    }
                    
                    Section(header: Text("Менеджер")) {
                        Text("Имя менеджера: \(viewModel.userProfile.managerName)")
                        Text("Телефон менеджера: \(viewModel.userProfile.managerPhoneNumber)")
                    }
                    
                    Section(header: Text("Остаток долга")) {
                        Text("Остаток долга: \(viewModel.userProfile.remainingDebt)")
                    }
                    
                    Section(header: Text("Избранные продукты")) {
                        ForEach(viewModel.userProfile.favoriteProducts, id: \.self) { productId in
                        Text("Продукт \(productId)")
                        }
                    }
                }
                .disabled(!viewModel.isEditing)
                
                // Поля редактирования
                if viewModel.isEditing {
                    VStack {
                        TextField("Название магазина", text: $viewModel.userProfile.storeName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                        
                        TextField("Адрес магазина", text: $viewModel.userProfile.storeAddress)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                        
                        TextField("Телефон магазина", text: $viewModel.userProfile.storePhoneNumber)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                        
                        TextField("Код магазина", text: $viewModel.userProfile.storeCode)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                        
                        TextField("Имя менеджера", text: $viewModel.userProfile.managerName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                        
                        TextField("Телефон менеджера", text: $viewModel.userProfile.managerPhoneNumber)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                        
                        TextField("Остаток долга", text: $viewModel.userProfile.remainingDebt)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                    }
                }
                
                Spacer()
            }
            .navigationTitle("Профиль")
        }
    }
}

