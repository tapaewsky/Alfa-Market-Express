//
//  ProductRowView.swift
//  WareHouse1
//
//  Created by Said Tapaev on 06.07.2024.
//
import SwiftUI
import Kingfisher

struct ProductRowView: View {
    var product: Product
    @StateObject var viewModel: MainViewModel
    var onFavoriteToggle: () -> Void

    var body: some View {
        HStack {
            productImage
            productDetails
            Spacer()
        }
        .padding()
    }
    
    private var productImage: some View {
        if let imageUrl = product.imageUrl, let url = URL(string: imageUrl) {
            return AnyView(
                KFImage(url)
                    .placeholder {
                        ProgressView()
                    }
                    .resizable()
                    .frame(width: 50, height: 50)
                    .aspectRatio(contentMode: .fill)
                    .clipped()
            )
        } else {
            return AnyView(
                Image(systemName: "photo")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .aspectRatio(contentMode: .fill)
                    .clipped()
            )
        }
    }
    
    private var productDetails: some View {
        VStack(alignment: .leading) {
            Text(product.name)
                .font(.headline)
                .foregroundColor(.black)
            
            HStack {
                favoriteButton
                priceText
            }
        }
    }
    
    private var favoriteButton: some View {
        Button(action: {
            onFavoriteToggle()
        }) {
            Image(systemName: product.isFavorite ? "heart.fill" : "heart")
                .foregroundColor(product.isFavorite ? .yellow : .gray)
                .padding(10)
        }
    }
    
    private var priceText: some View {
        if let price = Double(product.price) {
            return AnyView(
                Text(String(format: "%.0f ₽", price))
                    .font(.subheadline)
                    .foregroundColor(.black)
            )
        } else {
            return AnyView(
                Text("Цена не указана")
                    .font(.subheadline)
                    .foregroundColor(.black)
            )
        }
    }
}
