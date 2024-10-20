//
//  OrdersView.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 25.09.2024.
//

import SwiftUI

struct OrdersView: View {
    @StateObject var viewModel: MainViewModel
    @State private var isFetching: Bool = false
    
    var body: some View {
        ScrollView {
            VStack {
                    if viewModel.ordersViewModel.orders.isEmpty  && !isFetching {
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
            .onAppear {
                loadOrders()
            }
        }
    }
    
    private func loadOrders() {
        isFetching = true
        viewModel.ordersViewModel.fetchOrders { success in
            DispatchQueue.main.async {
                isFetching = false
                if success {
                    print("Заказы успешно загружены")
                } else {
                    print("Не удалось загрузить заказы")
                }
            }
        }
    }
}
