//
//  CartItemCheckout.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 22.10.2024.
//

import SwiftUI
import Kingfisher

// MARK: - CartItemCheckout

struct CartItemCheckout: View {
    @Binding var cartProduct: CartProduct
    
    var body: some View {
        HStack {
            productImage
            productDetails
            Spacer()
        }
        .padding(0)
        .background(RoundedRectangle(cornerRadius: 15).fill(Color.white).shadow(radius: 1))
    }
    
    private var productImage: some View {
        ProductImageView(imageUrl: cartProduct.product.imageUrl)
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
            
            ProductDescriptionView(description: cartProduct.product.description)
            QuantityView(quantity: cartProduct.quantity)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var totalPriceForProduct: Double {
        Double(cartProduct.quantity) * (Double(cartProduct.product.price) ?? 0.0)
    }
}

// MARK: - ProductImageView

struct ProductImageView: View {
    var imageUrl: String?
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            if let imageUrl = URL(string: imageUrl ?? "") {
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
}

// MARK: - ProductDescriptionView

struct ProductDescriptionView: View {
    var description: String
    
    var body: some View {
        HStack {
            Text(description)
                .font(.footnote)
                .lineLimit(2)
                .foregroundColor(.black)
            Spacer()
        }
    }
}

// MARK: - QuantityView

struct QuantityView: View {
    var quantity: Int
    
    var body: some View {
        HStack {
            Text("Кол-во: \(quantity)")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.trailing, 10)
        }
    }
}

// MARK: - Preview

//struct CartItemCheckout_Previews: PreviewProvider {
//    static var previews: some View {
//        // Предоставьте необходимые данные для превью
//        let product = Product(id: 1, name: "Тестовый продукт", price: "100", imageUrl: "http://example.com/image.png", description: "Описание продукта")
//        let cartProduct = CartProduct(product: product, quantity: 2)
//        CartItemCheckout(cartProduct: .constant(cartProduct))
//    }
//}
