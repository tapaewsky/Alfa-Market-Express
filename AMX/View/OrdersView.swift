//
//  OrdersView.swift
//  AlfaMarketExpress
//
//  Created by Said Tapaev on 24.12.2024.
//

import SwiftUI

struct OrdersView: View {
    @StateObject var viewModel: MainViewModel
    @State private var isFetching: Bool = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            if isFetching {
                Text("Загрузка заказов...")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding()
            } else if let orders = viewModel.ordersViewModel?.orders, orders.isEmpty {
                Text("Вы еще не сделали ни одного заказа.")
                    .font(.headline)
                    .padding()
            } else if let orders = viewModel.ordersViewModel?.orders {
                ScrollView {
                    Spacer()
                    ForEach(orders, id: \.id) { order in
                        NavigationLink(destination: OrdersDetail(order: order, viewModel: viewModel)) {
                            OrdersCard(order: order)
                                .padding(.vertical, 2)
                                .padding(.horizontal, 15)
                        }
                        .navigationBarHidden(true)

                        .buttonStyle(PlainButtonStyle())
                    }
                }
            } else {
                Text("Произошла ошибка при загрузке заказов.")
                    .foregroundColor(.red)
                    .font(.headline)
                    .padding()
            }
        }
        .navigationBarItems(leading: CustomBackButton {
            self.presentationMode.wrappedValue.dismiss()
        })
        .navigationBarBackButtonHidden(true)
        .onAppear {
            loadOrders()
        }
    }

    private func loadOrders() {
        isFetching = true
        viewModel.ordersViewModel?.fetchOrders { success in
            DispatchQueue.main.async {
                isFetching = false
                if !success {
                    print("Не удалось загрузить заказы")
                }
            }
        }
    }
}
