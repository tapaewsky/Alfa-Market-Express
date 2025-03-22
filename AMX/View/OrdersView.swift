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
                    .padding()
                    .foregroundColor(.gray)
            } else if let orders = viewModel.ordersViewModel?.orders {
                ScrollView {
                    Spacer()
                    ForEach(orders, id: \.id) { order in
                        NavigationLink(destination: OrdersDetail(order: order, viewModel: viewModel)) {
                            OrdersCard(order: order, cancelOrderAction: cancelOrder)
                                .padding(.vertical, 2)
                                .padding(.horizontal, 15)
                        }
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
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                CustomBackButton {
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .onAppear {
            loadOrders()
        }
    }


    private func cancelOrder(order: Order) {
        Task {
            await viewModel.ordersViewModel?.cancelOrder(orderId: order.id)
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

struct OrdersView_Preview: PreviewProvider {
    static var previews: some View {
        OrdersView(viewModel: MainViewModel())
    }
}
