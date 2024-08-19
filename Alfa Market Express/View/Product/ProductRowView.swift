//
//  ProductRowView.swift
//  WareHouse1
//
//  Created by Said Tapaev on 06.07.2024.
//

import SwiftUI

struct ProductRowView: View {
    var product: Product
    @ObservedObject var viewModel: ProductViewModel
    var onFavoriteToggle: () -> Void

    var body: some View {
        HStack {
            // Обработка опционального URL
            if let imageUrl = product.imageUrl, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image.resizable()
                        .frame(width: 50, height: 50)
                        .aspectRatio(contentMode: .fill)
                        .clipped()
                } placeholder: {
                    ProgressView()
                }
            } else {
                // Замена отсутствующего изображения на placeholder
                Image(systemName: "photo")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .aspectRatio(contentMode: .fill)
                    .clipped()
            }
            
            VStack(alignment: .leading) {
                Text(product.name)
                    .font(.headline)
                    .foregroundColor(.black)
                
                HStack {
                    Button(action: {
                        onFavoriteToggle()
                    }) {
                        Image(systemName: product.isFavorite ? "heart.fill" : "heart")
                            .foregroundColor(product.isFavorite ? .yellow : .gray)
                            .padding(10)
                    }
                    
                    
                    
                    // Обработка возможного преобразования строки в Double
                    if let price = Double(product.price) {
                        Text(String(format: "%.0f ₽", price))
                            .font(.subheadline)
                            .foregroundColor(.black)
                    } else {
                        Text("Цена не указана")
                            .font(.subheadline)
                            .foregroundColor(.black)
                    }
                }
            }
            
            
            Spacer()
        }
        .padding()
    }
}

