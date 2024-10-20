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
    var orderId: Int // Добавлено поле для идентификатора заказа
    
    var body: some View {
        HStack {
            productImage
            
            VStack(alignment: .leading) {
                productInfo
                priceInfo
                createdAtInfo
                statusInfo
            }
            
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
                    .frame(maxWidth: 50, maxHeight: 50)
                    .foregroundColor(.gray)
            }
            .resizable()
            .scaledToFit()
            .frame(maxWidth: 75, maxHeight: 100)
    }
    
    private var productInfo: some View {
        HStack {
            Text(orderItem.product)
                .font(.headline)
            
            Spacer()
            
            Text("ID: \(orderId)") // Изменено на отображение orderId
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
        
        let cleanDate = String(isoDate.prefix(10)) // "2024-10-10"
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        
        if let date = dateFormatter.date(from: cleanDate) {
            
            dateFormatter.dateFormat = "dd MMMM yyyy"
            dateFormatter.locale = Locale(identifier: "ru_RU") // Русская локализация
            return dateFormatter.string(from: date) // Возвращаем отформатированную дату
        }
        
        return cleanDate // Если преобразование не удалось, возвращаем исходное значение
    }
}



struct Preview_OrdersCard: PreviewProvider {
    static var previews: some View {
        OrdersCard(orderItem: OrderItem(product: "Pepsi",
                                        productId: 3,
                                        quantity: 1,
                                        price: 50.0, // Double
                                        image: "https://avatars.mds.yandex.net/get-mpic/6559549/2a0000018ac1d8e3008a371458cfe88c20e7/orig"),
                   createdAt: "2024-10-10T23:27:13.650331Z",
                   status: "обработка", orderId: 12)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
