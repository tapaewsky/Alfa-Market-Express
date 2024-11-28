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

//// Пример использования OrdersView с массивом OrderItem
//struct Preview_OrdersView: PreviewProvider {
//    static var previews: some View {
//        let orderItems = [
//            OrderItem(product: "Pepsi", productId: 3, quantity: 1, price: 50.0, image: "https://avatars.mds.yandex.net/get-mpic/6559549/2a0000018ac1d8e3008a371458cfe88c20e7/orig"),
//            OrderItem(product: "Coca Cola", productId: 4, quantity: 1, price: 55.0, image: "https://avatars.mds.yandex.net/get-mpic/6559549/2a0000018ac1d8e3008a371458cfe88c20e7/orig"),
//            OrderItem(product: "Sprite", productId: 5, quantity: 1, price: 45.0, image: "https://avatars.mds.yandex.net/get-mpic/6559549/2a0000018ac1d8e3008a371458cfe88c20e7/orig")
//        ]
//        
//        OrdersView(orderItems: orderItems, createdAt: "2024-10-10T23:27:13.650331Z", status: "обработка", orderId: 12)
//            .padding()
//    }
//}
