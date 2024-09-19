//
//   ProductDetailView.swift
//  WareHouse1
//
//  Created by Said Tapaev on 06.07.2024.
//
import SwiftUI
import Kingfisher

struct ProductDetailView: View {
    @ObservedObject var viewModel: MainViewModel
    var product: Product
    @State private var quantity: Int = 1
    @State private var isFavorite: Bool = false
    @State private var isAddedToCart: Bool = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ZStack(alignment: .topLeading) {
                    if let imageUrl = product.imageUrl, let url = URL(string: imageUrl) {
                        KFImage(url)
                            .placeholder {
                                ProgressView()
                            }
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: .infinity, maxHeight: 300)
                            .clipped()
                    } else {
                        Image(systemName: "photo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity, maxHeight: 300)
                            .background(Color.gray.opacity(0.2))
                    }
                }

                
                HStack {
                    Text(product.name)
                        .font(.title)
                        .padding(.horizontal)

                    Spacer()

                    Button(action: {
                        toggleFavorite()
                    }) {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(isFavorite ? .colorRed : .colorGray)
                            .padding()
                    }
                }

                Text(product.description)
                    .padding(.horizontal)

                let priceText = (Double(product.price) != nil) ? "\(product.price) ₽" : "Цена не доступна"
                Text(priceText)
                    .font(.title)
                    .padding(.horizontal)
                    .foregroundColor(.colorRed)

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

               
                Button(action: {
                    Task {
                        await toggleCart()
                    }
                }) {
                    Text(isAddedToCart ? "Удалить из корзины" : "Добавить в корзину")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(isAddedToCart ? Color.colorRed : Color.colorGreen)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .padding(.horizontal)

                
                Text("Похожие продукты")
                    .padding(.horizontal)

                LazyVGrid(columns: [GridItem(.flexible(), spacing: 1), GridItem(.flexible(), spacing: 10)], spacing: 5) {
                    ForEach(viewModel.productViewModel.filteredProducts) { product in
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
                .padding(.horizontal,10)
            }
            .padding(.vertical)
        }
        .navigationTitle("Информация о продукте")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            isFavorite = viewModel.favoritesViewModel.isFavorite(product)
            isAddedToCart = viewModel.cartViewModel.isInCart(product)
        }
    }

    private func toggleFavorite() {
        isFavorite.toggle()
        if isFavorite {
           viewModel.favoritesViewModel.addToFavorites(product)
        } else {
            viewModel.favoritesViewModel.removeFromFavorites(product)
        }
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
