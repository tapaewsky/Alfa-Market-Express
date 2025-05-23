//
//  ProductDetail.swift
//  AlfaMarketExpress
//
//  Created by Said Tapaev on 24.12.2024.
//

import Kingfisher
import SwiftUI

struct ProductDetailView: View {
    @StateObject var viewModel: MainViewModel
    var product: Product
    @State private var quantity: Int = 1
    @State private var isFavorite: Bool = false
    @State private var isAddedToCart: Bool = false
    @Environment(\.presentationMode) var presentationMode
    @State var authManager: AuthManager = .shared
    @State private var selectedIndex = 0
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                productImage
                productTitleAndFavoriteButton
                productDescription
                productPrice
                addToCartButton
            }
            
            .padding(.vertical)
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: CustomBackButton {
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
            VStack {
                TabView(selection: $selectedIndex) {
                    ForEach(Array(product.images.enumerated()), id: \.element.id) { index, productImage in
                        GeometryReader { geometry in
                            KFImage(URL(string: productImage.image))
                                .placeholder {
                                    ProgressView()
                                }
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: geometry.size.width, height: geometry.size.width * (4.0 / 3.0))
                                .clipped()
                                .allowsHitTesting(false)

                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .frame(height: UIScreen.main.bounds.width * (4.0 / 3.0))
                
                if !product.images.isEmpty {
                    HStack(spacing: 8) {
                        ForEach(product.images.indices, id: \.self) { index in
                            Circle()
                                .strokeBorder(Color.colorGreen, lineWidth: 1.5)
                                .background(Circle().fill(index == selectedIndex ? Color.colorGreen : Color.clear))
                                .frame(width: 10, height: 10)
                                .animation(.easeInOut(duration: 0.2), value: selectedIndex)
                        }
                    }
                }
            }
            
            if product.images.isEmpty {
                Image("placeholderProduct")
                    .resizable()
                    .scaledToFit()
            }
            
            Button(action: {
                if authManager.accessToken != nil {
                    Task {
                        await someFunctionThatCallsToggleFavorite()
                        isFavorite.toggle()
                    }
                } else {
                    NotificationCenter.default.post(name: Notification.Name("SwitchToProfile"), object: nil)
                }
            }) {
                Image(isFavorite ? "favorites_green_heart" : "favorites_white_heart")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)
            }
            .padding(20)
        }
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
            if authManager.accessToken != nil {
                Task {
                    await toggleCart()
                }
            } else {
                NotificationCenter.default.post(name: Notification.Name("SwitchToProfile"), object: nil)
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
