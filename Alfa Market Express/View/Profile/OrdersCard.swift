//
//  OrdersCard.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 10.10.2024.
//

import SwiftUI
import Kingfisher

struct OrdersCard: View {
    var orderItem: OrderItem
    var createdAt: String
    var status: String

    var body: some View {
        HStack {
            productImage
            
            VStack(alignment: .leading) {
                productInfo
                priceInfo
                createdAtInfo
                statusInfo
            }
            .padding(.leading)

            Spacer()
        }
        .padding(0)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 2)
    }

    private var productImage: some View {
        KFImage(URL(string: orderItem.image))
            .placeholder {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.gray)
            }
            .resizable()
            .scaledToFill()
            .frame(width: 100, height: 100)
    }

    private var productInfo: some View {
        HStack {
            Text(orderItem.product)
                .font(.headline)
            
            Spacer()
            
            Text("ID: \(orderItem.productId)")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
    
    private var priceInfo: some View {
        Text("\(String(format: "%.2f", orderItem.price)) ₽")
            .font(.subheadline)
            .foregroundColor(.colorRed)
    }
    
    private var createdAtInfo: some View {
        Text(formattedDate(from: createdAt))
            .font(.footnote)
            .foregroundColor(.gray)
    }
    
    private var statusInfo: some View {
        Text("Статус: \(status)")
            .font(.footnote)
            .foregroundColor(statusColor(for: status))
    }

    private func statusColor(for status: String) -> Color {
        switch status {
        case "обработка":
            return .orange
        case "сборка":
            return .yellow
        case "доставка":
            return .blue
        case "получен":
            return .green
        default:
            return .red
        }
    }

    // Форматирование даты в удобный вид
    private func formattedDate(from isoDate: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        if let date = isoFormatter.date(from: isoDate) {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            return formatter.string(from: date)
        }
        return isoDate
    }
}

// Пример для использования в PreviewProvider с настоящим JSON

struct Preview_OrdersCard: PreviewProvider {
    static var previews: some View {
        OrdersCard(orderItem: OrderItem(product: "Pepsi",
                                        productId: 3,
                                        quantity: 1,
                                        price: 50.0, // Double
                                        image: "https://ir.ozone.ru/s3/multimedia-l/wc1000/6897748341.jpg"),
                   createdAt: "2024-10-10T23:27:13.650331Z",
                   status: "обработка")
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
