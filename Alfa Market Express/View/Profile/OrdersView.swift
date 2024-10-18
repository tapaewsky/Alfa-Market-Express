//
//  OrdersView.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 25.09.2024.
//

import SwiftUI

struct OrdersView: View {
    @ObservedObject var viewModel: MainViewModel
    @State private var isFetching = false
    
    var body: some View {
        ScrollView {
            VStack {
                if isFetching {
                    ProgressView("Загрузка заказов...")
                } else {
                    if viewModel.ordersViewModel.orders.isEmpty {
                        Text("Заказы отсутствуют")
                            .font(.headline)
                            .padding()
                    } else {
                        ForEach(viewModel.ordersViewModel.orders, id: \.id) { order in
                            if let firstItem = order.items.first {
                                OrdersCard(orderItem: firstItem,
                                           createdAt: order.createdAt,
                                           status: order.status)
                                    .padding(.vertical, 2)
                                    .padding(.horizontal, 15)
                            }
                        }
                    }
                }
            }
            .onAppear {
                loadCart()
            }
        }
    }
    
    private func loadCart() {
        isFetching = true
        viewModel.ordersViewModel.fetchOrders { success in
            DispatchQueue.main.async {
                isFetching = false
                if success {
                    print("Избранное успешно загружена")
                } else {
                    print("Не удалось загрузить избранное")
                }
            }
        }
    }
}
