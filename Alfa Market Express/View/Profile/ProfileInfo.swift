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
                profileImage
                editButton
                profileForm
                Spacer()
            }
            .padding()
            .navigationTitle("Профиль")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private var profileImage: some View {
        if let url = URL(string: viewModel.userProfile.storeImageUrl) {
            return AnyView(
                KFImage(url)
                    .placeholder { ProgressView() }
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
            )
        }
        return AnyView(EmptyView())
    }
    
    private var editButton: some View {
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
    }
    
    private var profileForm: some View {
        Form {
            storeInfoSection
            managerInfoSection
            debtSection
            favoriteProductsSection
        }
        .disabled(!viewModel.isEditing)
    }
    
    private var storeInfoSection: some View {
        Section(header: Text("Информация о магазине")) {
            if viewModel.isEditing {
                editableStoreFields
            } else {
                displayStoreInfo
            }
        }
    }
    
    private var editableStoreFields: some View {
        Group {
            TextField("Название магазина", text: $viewModel.userProfile.storeName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("Адрес магазина", text: $viewModel.userProfile.storeAddress)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("Телефон магазина", text: $viewModel.userProfile.storePhoneNumber)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("Код магазина", text: $viewModel.userProfile.storeCode)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
    
    private var displayStoreInfo: some View {
        Group {
            Text("Название магазина: \(viewModel.userProfile.storeName)")
            Text("Адрес магазина: \(viewModel.userProfile.storeAddress)")
            Text("Телефон магазина: \(viewModel.userProfile.storePhoneNumber)")
            Text("Код магазина: \(viewModel.userProfile.storeCode)")
        }
    }
    
    private var managerInfoSection: some View {
        Section(header: Text("Менеджер")) {
            if viewModel.isEditing {
                editableManagerFields
            } else {
                displayManagerInfo
            }
        }
    }
    
    private var editableManagerFields: some View {
        Group {
            TextField("Имя менеджера", text: $viewModel.userProfile.managerName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("Телефон менеджера", text: $viewModel.userProfile.managerPhoneNumber)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
    
    private var displayManagerInfo: some View {
        Group {
            Text("Имя менеджера: \(viewModel.userProfile.managerName)")
            Text("Телефон менеджера: \(viewModel.userProfile.managerPhoneNumber)")
        }
    }
    
    private var debtSection: some View {
        Section(header: Text("Остаток долга")) {
            if viewModel.isEditing {
                TextField("Остаток долга", text: $viewModel.userProfile.remainingDebt)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            } else {
                Text("Остаток долга: \(viewModel.userProfile.remainingDebt)")
            }
        }
    }
    
    private var favoriteProductsSection: some View {
        Section(header: Text("Избранные продукты")) {
            ForEach(viewModel.userProfile.favoriteProducts, id: \.self) { productId in
                Text("Продукт \(productId)")
            }
        }
    }
}
