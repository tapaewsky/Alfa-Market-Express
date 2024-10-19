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
    @State var isFetching: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
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
            .padding()
            .onAppear() {
                loadProfile()
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
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
    
    
    
    private var shopOwner: some View {
        VStack  {
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
                Text("\(viewModel.profileViewModel.userProfile.firstName)")
                Text("\(viewModel.profileViewModel.userProfile.lastName)")
            }
                .foregroundColor(.gray)
                .bold()
            
//            Text("\(viewModel.profileViewModel.userProfile.username)")
//                .foregroundColor(.gray)
//                .bold()
            
            Text("\(viewModel.profileViewModel.userProfile.storeName)")
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
                
            
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
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
