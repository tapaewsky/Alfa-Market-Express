//
//  OrderDetail.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 28.11.2024.
//

import SwiftUI
import Kingfisher

struct OrdersDetail: View {
    var order: Order
    @StateObject var viewModel: MainViewModel
    @Environment(\.presentationMode) var presentationMode


    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(order.items, id: \.productId) { orderItem in
                    HStack {
                        productImage(for: orderItem)
                        VStack(alignment: .leading, spacing: 5) {
                            productInfo(for: orderItem)
                            priceInfo(for: orderItem)
                        }
                        Spacer()
                    }
                    .padding(0)
                    .background(Color.white)
                    .cornerRadius(15)
                    .shadow(radius: 2)
                    .padding(.vertical, 2)
                }
            }
            .padding()
        }
        .navigationBarItems(leading: CustomBackButton {
            self.presentationMode.wrappedValue.dismiss()
        })
        .navigationBarBackButtonHidden(true)
        .navigationTitle("Товары заказа №\(order.id)")
    }

    // MARK: - Components

    private func productImage(for orderItem: OrderItem) -> some View {
        ZStack {
            if let imageUrlString = orderItem.image, let imageUrl = URL(string: imageUrlString) {
                KFImage(imageUrl)
                    .placeholder {
                        Color.gray.opacity(0.3)
                    }
                    .resizable()
                    .scaledToFit()
                    .frame(width: 75, height: 100)
            } else {
                Image("plaseholderProduct")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 75, height: 100)
                    .foregroundColor(.gray)
            }
        }
    }

    private func productInfo(for orderItem: OrderItem) -> some View {
        VStack(alignment: .leading) {
            Text(orderItem.product)
                .font(.headline)
                .lineLimit(1)
                .truncationMode(.tail)
                .foregroundColor(.primary)
            
            Text("Кол-во: \(orderItem.quantity)")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }

    private func priceInfo(for orderItem: OrderItem) -> some View {
        Text(String(format: "%.0f₽", orderItem.price))
            .font(.subheadline)
            .foregroundColor(.red)
    }
}
