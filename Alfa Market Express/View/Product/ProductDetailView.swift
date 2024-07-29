//
//   ProductDetailView.swift
//  WareHouse1
//
//  Created by Said Tapaev on 06.07.2024.
//
import SwiftUI

struct ProductDetailView: View {
    @ObservedObject var viewModel: ProductViewModel
    var product: Product
    
    @State private var quantity: Int = 1
    @State private var isAddedToCart: Bool = false
    @State private var isFavorite: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ZStack(alignment: .topLeading) {
                    AsyncImage(url: URL(string: product.imageUrl)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(height: 300)
                    
                    Button(action: {
                        isFavorite.toggle()
                                                if isFavorite {
                                                    viewModel.addToFavorites(product)
                                                } else {
                                                    viewModel.removeFromFavorites(product)
                                                }
                    }) {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(isFavorite ? .red : .white)
                            .padding()
                    }
                }
                
                Text(product.name)
                    .font(.title)
                    .padding(.horizontal)
                
                Text(product.description)
                    .padding(.horizontal)
                
                Text("\(product.price) ₽")
                    .font(.title)
                    .padding(.horizontal)
                
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
                    if isAddedToCart {
                        viewModel.removeFromCart(product)
                    } else {
                        viewModel.addToCart(product)
                    }
                    isAddedToCart.toggle()
                }) {
                    Text(isAddedToCart ? "Удалить из корзины" : "Добавить в корзину")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(isAddedToCart ? Color.red : Color.green)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .padding(.horizontal)
                
                Section(header: Text("Похожие продукты")) {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(viewModel.products.filter { $0.category == product.category && $0.id != product.id }, id: \.id) { relatedProduct in
                            NavigationLink(destination: ProductDetailView(viewModel: viewModel, product: relatedProduct)) {
                                ProductCardView(product: relatedProduct, viewModel: viewModel, onFavoriteToggle: {})
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.vertical)
        }
        .navigationTitle("Информация о продукте")
        .navigationBarTitleDisplayMode(.inline)
    }
}

