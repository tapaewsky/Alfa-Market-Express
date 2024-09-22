//
//  FavoriteCard.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 21.09.2024.
//
import SwiftUI
import Kingfisher

struct FavoritesCardView: View {
    var product: Product
    @ObservedObject var viewModel: MainViewModel
    @State private var isFavorite = true
    @State private var isAddedToCart: Bool = false
    @State private var quantity: Int = 1
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(alignment: .top) {
                if let imageUrl = product.imageUrl, let url = URL(string: imageUrl) {
                    KFImage(url)
                        .placeholder {
                            ProgressView()
                                .frame(width: 100, height: 100)
                        }
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(product.name)
                        .font(.system(size: 14, weight: .semibold))
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.black)
                    
                    Spacer()
                        
                    Text("\(product.price) ₽")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.colorRed)
                }
                .padding(.vertical)
                
                Spacer()
                
                Button(action: {
                    isFavorite.toggle()
                }) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(isFavorite ? .colorRed : .gray)
                        .font(.system(size: 20))
                }
            }

            if isAddedToCart {
                Button(action: {
                    Task {
                        await toggleCart()
                    }
                }) {
                    Text("В корзине")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.clear)
                        .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.colorGreen, lineWidth: 1)
                                )
                        .foregroundColor(.colorGreen)
                        .cornerRadius(10)   
                }
            } else {
                Button(action: {
                    Task {
                        await toggleCart()
                    }
                }) {
                    Text("В корзину")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.colorGreen)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white)
                .shadow(radius: 1)
        )
    }
    
    private func toggleCart() async {
        if isAddedToCart {
            await viewModel.cartViewModel.removeFromCart(product)
        } else {
            await viewModel.cartViewModel.addToCart(product, quantity: quantity)
        }
        isAddedToCart.toggle()
    }
}
