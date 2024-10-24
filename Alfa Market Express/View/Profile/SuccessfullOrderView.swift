//
//  SuccessfullOrderView.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 11.10.2024.
//

import SwiftUI

struct SuccessfullOrderView: View {
    @State private var showOrders = false
    @StateObject var viewModel: MainViewModel
    @State private var showHome = false
    
    var body: some View {
        VStack {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 150))
                .foregroundColor(.colorGreen)
            
            
            Spacer()
            
            VStack(spacing: 10) {
                Text("Вы успешно сделали заказ!")
                    .font(.title2)
                    .foregroundColor(.black)
                    .bold()
                Text("Вы можете просмотреть свои заказы.")
                    .font(.subheadline)
                    .foregroundColor(.black)
            }
            
            Spacer()
            
            
            Button(action: {
                showOrders = true
            }) {
                Text("Мои заказы")
                    .padding(.vertical)
                    .padding(.horizontal, 140)
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .background(Color.colorGreen)
                    .cornerRadius(15)
                    .bold()
            }
            .background(
                NavigationLink(destination: OrdersView(viewModel: viewModel), isActive: $showOrders) {
                    EmptyView()
                }
            )

           
            Button(action: {
                showHome = true
            }) {
                Text("Главная")
                    .padding(.vertical)
                    .padding(.horizontal, 155)
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .background(Color.colorGreen)
                    .cornerRadius(15)
                    .bold()
            }
            .background(
                NavigationLink(destination: HomeView(viewModel: viewModel), isActive: $showHome) {
                    EmptyView()
                }
            )
        }
        .padding(.top, 150)
        .padding(.bottom, 100)
        .navigationBarBackButtonHidden(true)
    }
}

struct SuccessfullOrderView_Preview: PreviewProvider {
    static var previews: some View {
        SuccessfullOrderView(viewModel: MainViewModel())
    }
}
