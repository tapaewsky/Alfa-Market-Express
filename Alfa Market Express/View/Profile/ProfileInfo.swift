//
//  ProfileInfo.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 02.09.2024.
//

import SwiftUI
import Kingfisher

struct ProfileInfo: View {
    
    @ObservedObject var viewModel: ProfileViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                
                if let url = URL(string: viewModel.userProfile.storeImageUrl) {
                    KFImage(url)
                        .placeholder {
                            ProgressView()
                            
                        }
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                }
            
        
                
                HStack {
                    Button(action: {
                        viewModel.toggleEditing()
                    }) {
                        Text(viewModel.isEditing ? "Сохранить" : "Редактировать")
                            .fontWeight(.semibold)
                            .padding(8)
                            .background(Color.colorGreen)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding()
                
                Form {
                    // Информация о магазине
                    Section(header: Text("Информация о магазине")) {
                        if viewModel.isEditing {
                            TextField("Название магазина", text: $viewModel.userProfile.storeName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            TextField("Адрес магазина", text: $viewModel.userProfile.storeAddress)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            TextField("Телефон магазина", text: $viewModel.userProfile.storePhoneNumber)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            TextField("Код магазина", text: $viewModel.userProfile.storeCode)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        } else {
                            Text("Название магазина: \(viewModel.userProfile.storeName)")
                            Text("Адрес магазина: \(viewModel.userProfile.storeAddress)")
                            Text("Телефон магазина: \(viewModel.userProfile.storePhoneNumber)")
                            Text("Код магазина: \(viewModel.userProfile.storeCode)")
                        }
                    }
                    
                    // Информация о менеджере
                    Section(header: Text("Менеджер")) {
                        if viewModel.isEditing {
                            TextField("Имя менеджера", text: $viewModel.userProfile.managerName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            TextField("Телефон менеджера", text: $viewModel.userProfile.managerPhoneNumber)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        } else {
                            Text("Имя менеджера: \(viewModel.userProfile.managerName)")
                            Text("Телефон менеджера: \(viewModel.userProfile.managerPhoneNumber)")
                        }
                    }
                    
                    // Остаток долга
                    Section(header: Text("Остаток долга")) {
                        if viewModel.isEditing {
                            TextField("Остаток долга", text: $viewModel.userProfile.remainingDebt)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        } else {
                            Text("Остаток долга: \(viewModel.userProfile.remainingDebt)")
                        }
                    }
                    
                    // Избранные продукты
                    Section(header: Text("Избранные продукты")) {
                        ForEach(viewModel.userProfile.favoriteProducts, id: \.self) { productId in
                            Text("Продукт \(productId)")
                        }
                    }
                }
                .disabled(!viewModel.isEditing)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Профиль")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
