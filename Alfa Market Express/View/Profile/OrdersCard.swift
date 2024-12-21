//
//  OrdersCard.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 10.10.2024.
//

import SwiftUI
import Kingfisher

struct OrdersCard: View {
    var order: Order

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                orderInfo
                priceInfo
                createdAtInfo
            }
            .padding()

            Spacer()

            statusInfo
                .padding(.trailing, 16) // Отступ от края
        }
        .padding(0)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 2)
    }

    private var orderInfo: some View {
        HStack {
            Text("Заказ №\(order.id)")
                .font(.headline)
                .foregroundColor(.primary)

            Spacer()
        }
    }

    private var priceInfo: some View {
        Text("Сумма: \(Int(orderTotalPrice())) ₽")
            .font(.subheadline)
            .foregroundColor(.red)
    }

    private var createdAtInfo: some View {
        Text(formattedDate(from: order.createdAt))
            .font(.footnote)
            .foregroundColor(.gray)
    }

    private var statusInfo: some View {
        Text(orderStatusText)
            .font(.footnote)
            .fontWeight(.bold)
            .padding(8)
            .background(statusBackgroundColor)
            .cornerRadius(8)
            .foregroundColor(.white)
    }

    private var orderStatusText: String {
        print("\(order.status)")
        switch order.status
        {
        case "Получен":
            return "Получен"
        case "Отказано":
            return "Отказано"
        case "Обработка":
            return "Обработка"
        case "Доставка":
            return "Доставка"
        case "Сборка":
             return "Сборка"
        default:
            return "Неизвестно"
        }
    }

    private var statusBackgroundColor: Color {
        switch order.status {
        case "Получен":
            return Color.green
        case "Отказано":
            return Color.red
        case "Обработка":
            return Color.orange
        case "Доставка":
            return Color.blue
        case "Сборка":
            return Color.yellow
        default:
            return Color.gray
        }
    }

    private func orderTotalPrice() -> Double {
        order.items.reduce(0) { $0 + $1.price * Double($1.quantity) }
    }

    private func formattedDate(from isoDate: String) -> String {
        let cleanDate = String(isoDate.prefix(10))

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        if let date = dateFormatter.date(from: cleanDate) {
            dateFormatter.dateFormat = "dd MMMM yyyy"
            dateFormatter.locale = Locale(identifier: "ru_RU")
            return dateFormatter.string(from: date)
        }

        return cleanDate
    }
}
