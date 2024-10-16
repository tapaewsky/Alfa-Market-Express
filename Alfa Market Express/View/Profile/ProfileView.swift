//
//  ProfileView.swift
//  WareHouse1
//
//  Created by Said Tapaev on 06.07.2024.
//
import SwiftUI

struct ProfileView: View {
    @State private var selectedTab: Int = 0
    @ObservedObject var viewModel: MainViewModel
    
    var body: some View {
        VStack {
            HeaderView {
                Image("logo_v1")
                    .resizable()
                    .scaledToFit()
                    .padding(.horizontal)
            }
            NavigationButtons(selectedTab: $selectedTab)
            TabView(selection: $selectedTab) {
                ProfileInfo(viewModel: viewModel)
                    .tag(0)
                OrdersView(viewModel: viewModel)
                    .tag(1)
                EditProfile(viewModel: viewModel)
                    .tag(2)
            }
        }
        
        }
    }



struct NavigationButtons: View {
    @Binding var selectedTab: Int

    var body: some View {
        HStack(spacing: 10) {
            NavigationButton(title: "Профиль", tabIndex: 0, selectedTab: $selectedTab)
            NavigationButton(title: "Мои заказы", tabIndex: 1, selectedTab: $selectedTab)
            NavigationButton(title: "Редактировать", tabIndex: 2, selectedTab: $selectedTab)
        }
        .padding(.vertical, 15)
    }
}

struct NavigationButton: View {
    let title: String
    let tabIndex: Int
    @Binding var selectedTab: Int

    var body: some View {
        Button(action: {
            selectedTab = tabIndex
        }) {
            Text(title)
                .bold()
                .padding(.vertical, 10)
                .padding(.horizontal, 5)
                .background(selectedTab == tabIndex ? .colorGreen : Color.clear)
                .foregroundColor(selectedTab == tabIndex ? .white : .black)
                .cornerRadius(20)
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.colorGreen, lineWidth: 1))
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(viewModel: MainViewModel())
    }
}
