//
//  ProductDetail.swift
//  AlfaMarketExpress
//
//  Created by Said Tapaev on 24.12.2024.
//

import SwiftUI
import Kingfisher

struct ProductDetailView: View {
    @StateObject var viewModel: MainViewModel
    var product: Product
    @State private var quantity: Int = 1
    @State private var isFavorite: Bool = false
    @State private var isAddedToCart: Bool = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                productImage
                productTitleAndFavoriteButton
                productDescription
                productPrice
                addToCartButton
            }
            .background(Color("colorGray"))
            .padding(.vertical)
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: CustomBackButton() {
            self.presentationMode.wrappedValue.dismiss()
        })
        .navigationTitle("Информация о продукте")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            isFavorite = viewModel.favoritesViewModel.isFavorite(product)
        }
    }
    
        
    private var productImage: some View {
        ZStack(alignment: .topTrailing) {
            if let imageUrl = product.imageUrl, let url = URL(string: imageUrl) {
                KFImage(url)
                    .placeholder {
                        ProgressView()
                    }
                    .resizable()
                    .cornerRadius(20)
                    .scaledToFit()
            } else {
                Image("plaseholderProduct")
                    .resizable()
                    .cornerRadius(20)
                    .scaledToFit()
            }
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
            .padding()
        }
        .padding()
    }
    
    private var productTitleAndFavoriteButton: some View {
        HStack {
            Text(product.name)
                .font(.title)
                .padding(.horizontal)
            
        }
    }
    
    private var productDescription: some View {
        Text(product.description)
            .padding(.horizontal)
    }
    
    private var productPrice: some View {
        Text("\(Int(Double(product.price) ?? 0)) ₽")
            .font(.title)
            .padding(.horizontal)
            .foregroundColor(Color("colorRed"))
    }
    
    
    
    private var addToCartButton: some View {
        Button(action: {
            Task {
                await toggleCart()
            }
        }) {
            Text(isAddedToCart ? "Удалить из корзины" : "Добавить в корзину")
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, minHeight: 50)
                .background(isAddedToCart ? Color("colorRed") : Color("colorGreen"))
                .cornerRadius(10)
                .shadow(radius: 5)
        }
        .padding(.horizontal)
    }
    
    private var similarProductsSection: some View {
        VStack(alignment: .leading) {
            Text("Похожие товары")
                .padding(.horizontal)
                .bold()
            
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 1), GridItem(.flexible(), spacing: 10)], spacing: 5) {
                ForEach(viewModel.searchViewModel.filteredProducts) { product in
                    NavigationLink(destination: ProductDetailView(viewModel: viewModel, product: product)) {
                        ProductCardView(product: product, viewModel: viewModel, onFavoriteToggle: {
                            Task {
                                await viewModel.favoritesViewModel.toggleFavorite(for: product)
                            }
                        })
                        .padding(5)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 10)
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
    
    private func someFunctionThatCallsToggleFavorite() async {
        Task {
            await viewModel.favoritesViewModel.toggleFavorite(for: product)
        }
    }
}
