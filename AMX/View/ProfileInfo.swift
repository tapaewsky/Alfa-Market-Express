//
//  ProfileInfo.swift
//  AlfaMarketExpress
//
//  Created by Said Tapaev on 24.12.2024.
//

import SwiftUI
import Kingfisher

struct ProfileInfo: View {
    @ObservedObject var viewModel: MainViewModel
    @State private var isFetching: Bool = false
    @State private var showOrders = false
    @State private var showLogin = false
    @State private var showAlert = false
    
    var body: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                if isFetching {
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
    
    
    private var profileImage: some View {
        Group {
            if let storeImageUrl = viewModel.profileViewModel.userProfile.storeImageUrl,
               let url = URL(string: storeImageUrl) {
                KFImage(url)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 350, height: 200)
                    .cornerRadius(10)
            } else {
                Image("placeholderStoreImage")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 350, height: 200)
                    .cornerRadius(10)
            }
        }
    }
    
    
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
                .foregroundColor(Color("colorGreen"))
                .bold()

            Text("Телефон: ")
                .foregroundColor(.gray)
                .bold() +
            Text(viewModel.profileViewModel.userProfile.storePhoneNumber)
                .foregroundColor(Color("colorGreen"))
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
                .foregroundColor(Color("colorGreen"))
                .bold()

            Spacer()

            VStack(spacing: 10) {
                ordersButton
                exitButton
            }

            NavigationLink(destination: OrdersView(viewModel: viewModel), isActive: $showOrders) {
                EmptyView()
            }
            NavigationLink(destination: LoginView(viewModel: viewModel), isActive: $showLogin){
                EmptyView()
            }}
        .padding()
    }
    
    private var ordersButton: some View {
        Button(action: {
            showOrders = true
        }) {
            Text("Мои заказы")
                .font(.subheadline)
                .foregroundColor(Color("colorGreen"))
                .frame(maxWidth: .infinity)
                .padding()
                .background(.white)
                .cornerRadius(10)
        }
        .shadow(radius: 1)
    }

    private var exitButton: some View {
        Button(action: {
            showAlert = true
        }) {
            Text("Выйти из аккаунта")
                .font(.subheadline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color("colorRed"))
                .cornerRadius(10)
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Выход из аккаунта"),
                message: Text("Вы уверены, что хотите выйти из аккаунта?"),
                primaryButton: .destructive(Text("Выйти")) {
                    showLogin = true
                    viewModel.authManager.logOut()
                    print("Кнопка нажата")
                },
                secondaryButton: .cancel(Text("Отмена"))
            )
        }
    }

    
    private func loadProfile() {
        isFetching = true
        viewModel.profileViewModel.fetchUserProfile { success in
            DispatchQueue.main.async {
                isFetching = false
                if success {
                } else {
                    print("Не удалось загрузить профиль")
                }
            }
        }
    }
}
