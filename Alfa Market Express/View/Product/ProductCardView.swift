//
//   ProductCardView.swift
//  WareHouse1
//
//  Created by Said Tapaev on 06.07.2024.
//

import SwiftUI

struct ProductCardView: View {
    let product: Product
    @ObservedObject var viewModel: ProductViewModel
    var onFavoriteToggle: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .topTrailing) {
              
                if let imageUrl = product.imageUrl, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .cornerRadius(10)
                            .clipped()
                            .background(.clear)

                    } placeholder: {
                        ProgressView()
                    }
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .cornerRadius(10)
                        .clipped()
                }

                Button(action: {
                    onFavoriteToggle()
                }) {
                    Image(systemName: product.isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(product.isFavorite ? .red : .gray)
                        .padding(10)
                }
            }

            Text(product.name)
                .font(.subheadline)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text("Цена за 1 шт")
                .foregroundStyle(.gray)
            
            Spacer()
            
            HStack {
                Text(String(format: "%.0f₽", Double(product.price) ?? 0))
                    .font(.headline)
                    .foregroundColor(.red)
                
                Spacer()
                
                Image(systemName: "cart")
                    .padding(10)
                    .foregroundColor(.white)
                    .background(product.isInCart ? .gray : .main)
                    .cornerRadius(30)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 7)
    }
}
