//
//  FavoritesCardView.swift
//  AlfaMarketExpress
//
//  Created by Said Tapaev on 24.12.2024.
//

import Kingfisher
import SwiftUI

struct FavoritesCardView: View {
    var product: Product
    @ObservedObject var viewModel: MainViewModel
    @State private var isFavorite = true
    @State private var isAddedToCart: Bool = false
    @State private var quantity: Int = 1

    var body: some View {
        VStack(spacing: 12) {
            productImageAndInfo
            cartButton
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white)
                .shadow(radius: 1)
        )
    }

    private var productImageAndInfo: some View {
        HStack(alignment: .top) {
            productImage
            productInfo
            Spacer()
            favoriteButton
        }
    }

    private var productImage: some View {
        Group {
            if let imageUrl = product.imageUrl, let url = URL(string: imageUrl) {
                KFImage(url)
                    .placeholder { ProgressView() }
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: 115, maxHeight: 150)
                    .cornerRadius(15)
            } else {
                Image("placeholderProduct")
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: 115, maxHeight: 150)
                    .cornerRadius(15)
            }
        }
    }

    private var productInfo: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(product.name)
                .font(.system(size: 14, weight: .semibold))
                .multilineTextAlignment(.leading)
                .foregroundColor(.black)
            Text("\(Int(Double(product.price) ?? 0)) ₽")
                .font(.headline)
                .foregroundColor(.black)
        }
        .padding(.vertical)
    }

    private var favoriteButton: some View {
        Button(action: {
            Task {
                await someFunctionThatCallsToggleFavorite()
                isFavorite.toggle()
            }
        }) {
            Image(isFavorite ? "favorites_green_heart" : "favorites_white_heart")
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
        }
    }

    private var cartButton: some View {
        Button(action: {
            Task {
                await toggleCart()
            }
        }) {
            if isAddedToCart {
                Text("В корзине")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color("colorGreen"), lineWidth: 1)
                    )
                    .foregroundColor(Color("colorGreen"))
            } else {
                Text("В корзину")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("colorGreen"))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
    }

    private func someFunctionThatCallsToggleFavorite() async {
        Task {
            await viewModel.favoritesViewModel.toggleFavorite(for: product)
        }
    }

    private func toggleCart() async {
        if isAddedToCart {
            await viewModel.cartViewModel.removeFromCard(product)
        } else {
            await viewModel.cartViewModel.addToCart(product, quantity: quantity)
        }
        isAddedToCart.toggle()
    }
}
