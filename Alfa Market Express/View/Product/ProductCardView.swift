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
    @ObservedObject var viewModel: MainViewModel
    var onFavoriteToggle: () -> Void
    @State private var quantity: Int = 1
    @State private var isFavorite: Bool = false
    @State private var isAddedToCart: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            productImageAndFavoriteButton
            productDetails
            productPriceAndCartButton
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
        .onAppear {
            isFavorite = viewModel.favoritesViewModel.isFavorite(product)
            isAddedToCart = viewModel.cartViewModel.isInCart(product)
        }
    }
    
    // MARK: - Приватные функции для отдельных частей представления

    private var productImageAndFavoriteButton: some View {
        ZStack(alignment: .topTrailing) {
            if let imageUrl = product.imageUrl, let url = URL(string: imageUrl) {
                KFImage(url)
                    .placeholder {
                        ProgressView()
                            .frame(width: 150, height: 100)
                    }
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .cornerRadius(10)
                    .clipped()
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .cornerRadius(10)
                    .clipped()
            }
            
            Button(action: {
                someFunctionThatCallsToggleFavorite(product)
            }) {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .foregroundColor(isFavorite ? .red : .gray)
                    .padding(5)

                    .cornerRadius(10)
            }
        }
    }
    
    private var productDetails: some View {
        VStack(alignment: .leading) {
            Text(product.name)
                .font(.subheadline)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text("Цена за 1 шт")
                .foregroundStyle(.gray)
        }
    }
    
    private var productPriceAndCartButton: some View {
        HStack {
            Text(String(format: "%.0f₽", Double(product.price) ?? 0))
                .font(.headline)
                .foregroundColor(.red)
            
            Spacer()
            
            Button(action: {
                Task {
                    await toggleCart()
                }
            }) {
                Image(systemName: isAddedToCart ? "cart.fill" : "cart")
                    .padding(10)
                    .foregroundColor(.white)
                    .background(isAddedToCart ? Color.gray : Color.colorGreen)
                    .cornerRadius(30)
                    .shadow(radius: 5)
            }
        }
    }

    // MARK: - Логика для работы с корзиной и избранным

    private func toggleCart() async {
        if isAddedToCart {
            await viewModel.cartViewModel.removeFromCart(product)
        } else {
            await viewModel.cartViewModel.addToCart(product, quantity: quantity)
        }
        isAddedToCart.toggle()
    }
    
    private func someFunctionThatCallsToggleFavorite(_ product: Product) {
        Task {
            await viewModel.favoritesViewModel.toggleFavorite(for: product)
        }
    }
}
