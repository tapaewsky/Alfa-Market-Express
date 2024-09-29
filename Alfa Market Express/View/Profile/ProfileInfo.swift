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
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    profileImage
                    shopOwner
                    displayStoreInfo
                    
                    Spacer()
                }
            }
            .padding()
            
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private var profileImage: some View {
        if let url = URL(string: viewModel.profileViewModel.userProfile.storeImageUrl) {
            return AnyView(
                KFImage(url)
                    .placeholder { ProgressView() }
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame( height: 200)  // Установите только высоту, чтобы автоматически подстраивать ширину
                    .cornerRadius(20)
                    .padding(.horizontal,5)  // Добавляем одинаковые отступы слева и справа
                    .frame(maxWidth: .infinity)  // Занимаем всю доступную ширину
                   
            )
        }
        
        return AnyView(EmptyView())
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
            Text("\(viewModel.profileViewModel.userProfile.username)")
                .foregroundColor(.gray)
                .bold()
            
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
            
            Text(viewModel.profileViewModel.userProfile.storePhoneNumber)
                .foregroundColor(.colorGreen)
                .bold()
                
            
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    
}
