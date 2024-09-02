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

    private let customGreen = Color(red: 38 / 255, green: 115 / 255, blue: 21 / 255)

    var body: some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .topTrailing) {
                // Проверка и обработка опционального URL
                if let imageUrl = product.imageUrl, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                            .cornerRadius(10)
                            .clipped()

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
                        .foregroundColor(product.isFavorite ? .yellow : .gray)
                        .padding(10)
                }
            }

            Text(String(format: "%.0f₽", Double(product.price) ?? 0))
                .font(.headline)
                .foregroundColor(.black)

            Text(product.name)
                .font(.subheadline)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .foregroundColor(.primary)

            Spacer()

            if product.isInCart {
                HStack {
                    Button(action: {
                        if product.quantity > 1 {
                            viewModel.addToCart(product)
                        } else {
                            viewModel.removeFromCart(product)
                        }
                    }) {
                        Image(systemName: "minus")
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(4)
                    }

                    Text("\(product.quantity) кг")
                        .padding(.horizontal)
                        .font(.body)
                        .foregroundColor(.black)

                    Button(action: {
                        viewModel.addToCart (product)
                    }) {
                        Image(systemName: "plus")
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(4)
                    }
                }
                .padding(.top, 10)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
            } else {
                Button(action: {
                    viewModel.addToCart(product)
                }) {
                    Text("В корзину")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(customGreen)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)

    }
}







