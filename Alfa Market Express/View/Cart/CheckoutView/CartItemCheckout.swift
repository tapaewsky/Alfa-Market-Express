//
//  CartItemCheckout.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 22.10.2024.
//

import SwiftUI
import Kingfisher

struct CartItemCheckout: View {
    @Binding var cartProduct: CartProduct
    
    private var totalPriceForProduct: Double {
        Double(cartProduct.quantity) * (Double(cartProduct.product.price) ?? 0.0)
    }

    var body: some View {
        HStack {
            productImage
            productDetails
            Spacer()
        }
        .padding(0)
        .background(RoundedRectangle(cornerRadius: 15).fill(Color.white).shadow(radius: 1))
    }
    private func updateQuantity(newQuantity: Int) {
            // Обновляем количество товара в cartProduct и пересчитываем цену
            cartProduct.quantity = newQuantity
           
        }
    
    private var productImage: some View {
        ZStack(alignment: .topLeading) {
            if let imageUrl = URL(string: cartProduct.product.imageUrl ?? "") {
                KFImage(imageUrl)
                    .placeholder { ProgressView() }
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: 115, maxHeight: 150)
                    .cornerRadius(15)
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: 115, maxHeight: 150)
            }
        }
    }
    
    private var productDetails: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(cartProduct.product.name)
                .font(.headline)
                .lineLimit(1)
                .foregroundColor(.black)
            
            Text("\(Int(totalPriceForProduct)) ₽")
                .font(.subheadline)
                .foregroundColor(.colorRed)
            HStack {
                Text(cartProduct.product.description)
                    .font(.footnote)
                    .lineLimit(2)
                    .foregroundColor(.black)
                Spacer()
                Text("Кол-во: \(cartProduct.quantity)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.trailing, 10)
            }
        
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var quantityView: some View {
        Text("Количество: \(cartProduct.quantity)")
            .font(.subheadline)
            .foregroundColor(.gray)
            .padding(.trailing, 10)
    }
}
