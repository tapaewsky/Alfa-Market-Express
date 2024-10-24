//
//  ProfileInfo.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 02.09.2024.
//
import SwiftUI
import Kingfisher

struct ProfileInfo: View {
    @ObservedObject var viewModel: MainViewModel
    @State private var isFetching: Bool = false
    @State private var showOrders = false

    var body: some View {
        VStack {
            ScrollView {
                if isFetching {
                    ProgressView() 
                } else if viewModel.profileViewModel.userProfile == nil {
                    Text("Нет данных о профиле")
                        .padding()
                } else {
                    profileImage
                    shopOwner
                    displayStoreInfo
                }

                Spacer()
            }
        }
        .onAppear {
            loadProfile()
        }
    }
    
    // MARK: - Profile Image
    
    private var profileImage: some View {
        Group {
            if let storeImageUrl = viewModel.profileViewModel.userProfile.storeImageUrl,
               let url = URL(string: storeImageUrl) {
                KFImage(url)
                    .placeholder { ProgressView() }
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .cornerRadius(20)
                    .frame(maxWidth: .infinity)
            } else {
                EmptyView()
            }
        }
    }
    
    // MARK: - Shop Owner Information
    
    private var shopOwner: some View {
        VStack {
            Text("Владелец магазина")
                .font(.title2)
                .foregroundColor(.black)
                .bold()
            
            Divider()
                .background(.gray)
        }
        .padding()
    }
    
    // MARK: - Display Store Information
    
    private var displayStoreInfo: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text(viewModel.profileViewModel.userProfile.firstName)
                Text(viewModel.profileViewModel.userProfile.lastName)
            }
            .foregroundColor(.gray)
            .bold()
            
            Text(viewModel.profileViewModel.userProfile.storeName)
                .foregroundColor(.black)
                .bold()
            
            Text("Адрес: ")
                .foregroundColor(.gray)
                .bold() +
            Text(viewModel.profileViewModel.userProfile.storeAddress)
                .foregroundColor(.colorGreen)
                .bold()
            
            Text("Телефон: ")
                .foregroundColor(.gray)
                .bold() +
            Text(viewModel.profileViewModel.userProfile.storePhoneNumber)
                .foregroundColor(.colorGreen)
                .bold()
            
            Text("Код магазина: \(viewModel.profileViewModel.userProfile.storeCode)")
                .foregroundColor(.gray)
                .bold()
            
            Divider()
                .background(.gray)
            
            Text("Ваш менеджер \(viewModel.profileViewModel.userProfile.managerName)")
                .foregroundColor(.black)
                .bold()
            
            Text(viewModel.profileViewModel.userProfile.managerPhoneNumber)
                .foregroundColor(.colorGreen)
                .bold()
            
            Spacer()
            
            ordersButton
            
            NavigationLink(destination: OrdersView(viewModel: viewModel), isActive: $showOrders) {
                EmptyView()
            }
        }
        .padding()
    }
    
    // MARK: - Orders Button
    
    private var ordersButton: some View {
        Button(action: {
            showOrders = true
        }) {
            Text("Мои заказы")
                .font(.subheadline)
                .foregroundColor(.colorGreen)
                .frame(maxWidth: .infinity)
                .padding()
                .background(.white)
                .cornerRadius(10)
        }
        .shadow(radius: 3)
    }

    // MARK: - Load Profile
    
    private func loadProfile() {
        isFetching = true
        viewModel.profileViewModel.fetchUserProfile { success in
            DispatchQueue.main.async {
                isFetching = false
                if success {
                    print("Профиль успешно загружен")
                } else {
                    print("Не удалось загрузить профиль")
                }
            }
        }
    }
}
