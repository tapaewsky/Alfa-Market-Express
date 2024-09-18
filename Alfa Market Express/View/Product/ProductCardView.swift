//
//   ProductCardView.swift
//  WareHouse1
//
//  Created by Said Tapaev on 06.07.2024.
//

import SwiftUI
import Kingfisher

struct ProductCardView: View {
    let product: Product
    @ObservedObject var viewModel: ProductViewModel
    var onFavoriteToggle: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .topTrailing) {
                
                if let imageUrl = product.imageUrl, let url = URL(string: imageUrl) {
                    KFImage(url)
                        .placeholder {
                            ProgressView()
                                .frame(width: 150, height: 100)
                        }
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 150,height: 150)
                        .cornerRadius(10)
                        .clipped()
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 150, height: 150)
                        .cornerRadius(10)
                        .clipped()
                }
                
                Button(action: {
                    onFavoriteToggle()
                }) {
                    Image(systemName: product.isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(product.isFavorite ? .colorRed : .colorGreen)
                        .padding(5)
                        .background(.colorGray)
                        .cornerRadius(10)
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
            
            HStack {
                Text(String(format: "%.0f₽", Double(product.price) ?? 0))
                    .font(.headline)
                    .foregroundColor(.red)
                
                Spacer()
                
                Image(systemName: "cart")
                    .padding(10)
                    .foregroundColor(.white)
                    .background(product.isInCart ? Color.gray : Color.colorGreen)
                    .cornerRadius(30)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 1)
    }
}
