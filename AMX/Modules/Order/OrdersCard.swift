//
//  OrdersCard.swift
//  AlfaMarketExpress
//
//  Created by Said Tapaev on 24.12.2024.
//

// import SwiftUI
// import Kingfisher
//
// struct OrdersCard: View {
//    var order: Order
//
//    var body: some View {
//        HStack {
//            VStack(alignment: .leading) {
//                orderInfo
//                priceInfo
//                createdAtInfo
//            }
//            .padding()
//
//            Spacer()
//
//            statusInfo
//                .padding(.trailing, 16)
//        }
//        .padding(0)
//        .background(Color.white)
//        .cornerRadius(15)
//        .shadow(radius: 2)
//    }
//
//    private var orderInfo: some View {
//        HStack {
//            Text("Заказ №\(order.id)")
//                .font(.headline)
//                .foregroundColor(.primary)
//
//            Spacer()
//        }
//    }
//
//    private var priceInfo: some View {
//        Text("Сумма: \(Int(orderTotalPrice())) ₽")
//            .font(.subheadline)
//            .foregroundColor(.red)
//    }
//
//    private var createdAtInfo: some View {
//        Text(formattedDate(from: order.createdAt))
//            .font(.footnote)
//            .foregroundColor(.gray)
//    }
//
//    private var statusInfo: some View {
//        Text(orderStatusText)
//            .font(.footnote)
//            .fontWeight(.bold)
//            .padding(8)
//            .background(statusBackgroundColor)
//            .cornerRadius(8)
//            .foregroundColor(.white)
//    }
//
//    private var orderStatusText: String {
//        print("\(order.status)")
//        switch order.status
//        {
//        case "получен":
//            return "получен"
//        case "отказано":
//            return "отказано"
//        case "обработка":
//            return "обработка"
//        case "доставка":
//            return "доставка"
//        case "сборка":
//             return "сборка"
//        case "отменен":
//            return "отменен"
//        default:
//            return order.status
//        }
//    }
//
//    private var statusBackgroundColor: Color {
//        switch order.status {
//        case "получен":
//            return Color.green
//        case "отказано":
//            return Color.red
//        case "обработка":
//            return Color.orange
//        case "доставка":
//            return Color.blue
//        case "сборка":
//            return Color.yellow
//        default:
//            return Color.gray
//        }
//    }
//
//    private func orderTotalPrice() -> Double {
//        order.items.reduce(0) { $0 + $1.price * Double($1.quantity) }
//    }
//
//    private func formattedDate(from isoDate: String) -> String {
//        let cleanDate = String(isoDate.prefix(10))
//
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd"
//
//        if let date = dateFormatter.date(from: cleanDate) {
//            dateFormatter.dateFormat = "dd MMMM yyyy"
//            dateFormatter.locale = Locale(identifier: "ru_RU")
//            return dateFormatter.string(from: date)
//        }
//
//        return cleanDate
//    }
// }
import Kingfisher
import SwiftUI

struct OrdersCard: View {
    var order: Order
    var cancelOrderAction: (Order) -> Void
    @State private var currentOrderStatus: String

    init(order: Order, cancelOrderAction: @escaping (Order) -> Void) {
        self.order = order
        self.cancelOrderAction = cancelOrderAction
        _currentOrderStatus = State(initialValue: order.status)
    }

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
                .padding(.trailing, 16)

            if currentOrderStatus == "обработка" {
                Menu {
                    Button(action: {
                        cancelOrderAction(order)
                        currentOrderStatus = "отменен"
                    }) {
                        Text("Отменить заказ")
                        Image(systemName: "xmark.circle.fill")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.title)
                        .padding(16)
                        .foregroundColor(.gray)
                }
            }
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
        Text(currentOrderStatus)
            .font(.footnote)
            .fontWeight(.bold)
            .padding(8)
            .background(statusBackgroundColor)
            .cornerRadius(8)
            .foregroundColor(.white)
    }

    private var statusBackgroundColor: Color {
        switch currentOrderStatus {
            case "получен": Color.green
            case "отказано": Color.red
            case "обработка": Color.orange
            case "доставка": Color.blue
            case "сборка": Color.yellow
            case "отменен": Color.gray
            default: Color.gray
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
