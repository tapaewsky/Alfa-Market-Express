//
//   ProductDetailView.swift
//  WareHouse1
//
//  Created by Said Tapaev on 06.07.2024.
//
import SwiftUI
import Kingfisher

struct ProductDetailView: View {
    @StateObject var viewModel: MainViewModel
    var product: Product
    @State private var quantity: Int = 1
    @State private var isFavorite: Bool = false
    @State private var isAddedToCart: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                productImage
                productTitleAndFavoriteButton
                productDescription
                productPrice
//                productQuantityStepper
                addToCartButton
                similarProductsSection
            }
            .background(.colorGray)
            .padding(.vertical)
        }
        .navigationTitle("Информация о продукте")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            isFavorite = viewModel.favoritesViewModel.isFavorite(product)
            isAddedToCart = viewModel.cartViewModel.isInCart(product)
        }
    }
    
    // MARK: - Приватные функции для отдельных частей представления
    
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
                Image(systemName: "photo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
//                    .frame(maxWidth: .infinity, maxHeight: 400)
                    .background(Color.gray.opacity(0.2))
            }
            Button(action: {
                Task {
                    await viewModel.favoritesViewModel.toggleFavorite(for: product)
                }
            }) {
                Image(systemName: viewModel.favoritesViewModel.isFavorite(product) ? "heart.fill" : "heart")
                    .foregroundColor(viewModel.favoritesViewModel.isFavorite(product) ? .colorGreen: .gray)
                    .padding()
            }
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
        let priceText = (Double(product.price) != nil) ? "\(product.price) ₽" : "Цена не доступна"
        return Text(priceText)
            .font(.title)
            .padding(.horizontal)
            .foregroundColor(.colorRed)
    }
    
    private var productQuantityStepper: some View {
        HStack {
            Text("Количество:")
                .font(.title3)
                .padding(.horizontal)
            
            Stepper(value: $quantity, in: 1...1000) {
                Text("\(quantity)")
                    .font(.title3)
            }
            .padding(.horizontal)
        }
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
                    .background(isAddedToCart ? .colorRed : .colorGreen)
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
    
    // MARK: - Логика для работы с корзиной и избранным
    
    private func toggleCart() async {
        if isAddedToCart {
            await viewModel.cartViewModel.removeFromCard(product)
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
