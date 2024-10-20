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

    var body: some View {
        HStack {
            VStack(spacing: 16) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title)
                    .foregroundColor(.colorGreen)
                Text("Вы успешно сделали заказ!")
                    .font(.headline)
                    .foregroundColor(.colorGreen)
                Text("Вы можете просмотреть свои заказы.")
                    .font(.headline)
                    .foregroundColor(.black)

                Button(action: {
                    showOrders = true
                }) {
                    Text("Мои заказы")
                        .padding(.vertical)
                        .padding(.horizontal, 20)
                        .font(.headline)
                        .foregroundColor(.black)
                        .cornerRadius(20)
                }
                .background(Color.white)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.colorGreen, lineWidth: 2)
                )
                .background(
                    NavigationLink(destination: OrdersView(viewModel: viewModel), isActive: $showOrders) {
                        EmptyView()
                    }
                )
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 2)
        }
       
        .navigationBarBackButtonHidden(true)

    }
}

struct SuccessfullOrderView_Preview: PreviewProvider {
    static var previews: some View {
        SuccessfullOrderView(viewModel: MainViewModel())
    }
}
