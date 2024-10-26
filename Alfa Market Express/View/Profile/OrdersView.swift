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
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            if viewModel.ordersViewModel!.orders.isEmpty  && !isFetching {
                Text("Заказы отсутствуют")
                    .font(.headline)
                    .padding()
            } else {
                ScrollView {
                    Spacer()
                    ForEach(viewModel.ordersViewModel!.orders, id: \.id) { order in
                        if let firstItem = order.items.first {
                            OrdersCard(orderItem: firstItem,
                                       createdAt: order.createdAt,
                                       status: order.status, orderId: order.id)
                            .padding(.vertical, 2)
                            .padding(.horizontal, 15)
                        }
                        
                    }
                    .navigationBarItems(leading: CustomBackButton() {
                        self.presentationMode.wrappedValue.dismiss()
                    })
                    .navigationBarBackButtonHidden(true)
                }
            }
        }
        .onAppear {
            loadOrders()
        }
    }
    
    private func loadOrders() {
        isFetching = true
        viewModel.ordersViewModel!.fetchOrders { success in
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
