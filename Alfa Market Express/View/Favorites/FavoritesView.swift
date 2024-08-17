//
//  FavoritesView.swift
//  WareHouse1
//
//  Created by Said Tapaev on 06.07.2024.
//

import SwiftUI

struct FavoritesView: View {
    @ObservedObject var viewModel: ProductViewModel
    @State private var isSelecting: Bool = false
    @State private var selectedProducts: Set<Product> = []
    private let customGreen = Color(red: 38 / 255, green: 115 / 255, blue: 21 / 255)
    @State private var searchText = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                HStack {
                    SearchBar(searchText: $searchText, customGreen: customGreen, viewModel: viewModel)
                        .padding(.vertical, 0)
                        .padding(.horizontal, 0)

                    if isSelecting {
                        Button(action: {
                            selectedProducts = Set(viewModel.favorites)
                        }) {
                            Text("Выбрать все")
                                .font(.subheadline)
                                .foregroundColor(.white)
                        }
                        .padding(.trailing, 10)
                    }
                }
                .padding(5)
                .background(customGreen)
                
                if isSelecting {
                    HStack {
                        Button(action: {
                            isSelecting.toggle()
                            selectedProducts.removeAll()
                        }) {
                            Text("Отменить")
                                .font(.headline)
                                .padding()
                                .foregroundColor(.white)
                        }
                        .padding(.leading, 10)

                        Spacer()
                        
                        Button(action: {
                            viewModel.addSelectedProductsToCart()
                            selectedProducts.removeAll()
                        }) {
                            HStack {
                                Image(systemName: "cart.fill")
                            }
                            .font(.headline)
                            .padding()
                            .foregroundColor(.white)
                        }
                        .padding(.trailing, 10)
                        
                        Button(action: {
                            viewModel.removeSelectedProducts()
                            selectedProducts.removeAll()
                        }) {
                            HStack {
                                Image(systemName: "trash.fill")
                            }
                            .font(.headline)
                            .padding()
                            .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal)
                    .background(customGreen)
                }

                List(viewModel.favorites) { product in
                    HStack {
                        if isSelecting {
                            Image(systemName: selectedProducts.contains(product) ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(selectedProducts.contains(product) ? .red : .gray)
                                .onTapGesture {
                                    viewModel.toggleProductSelection(product)
                                }
                        }

                        NavigationLink(destination: ProductDetailView(viewModel: viewModel, product: product)) {
                            HStack(spacing: 10) {
                                AsyncImage(url: URL(string: product.imageUrl)) { image in
                                    image.resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 50, height: 50)
                                        .cornerRadius(8)
                                } placeholder: {
                                    ProgressView()
                                        .frame(width: 50, height: 50)
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(product.name)
                                        .font(.headline)
                                        .lineLimit(1)

                                    Text("\(product.price) ₽")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        Spacer()
                        Button(action: {
                            viewModel.addSelectedProductsToCart()
                            selectedProducts.removeAll()
                        }) {
                            HStack {
                                Image(systemName: "cart.fill")
                                    .foregroundColor(customGreen)
                               
                            }
                        }
                        Spacer()
                        Button(action: {
                            viewModel.removeSelectedProducts()
                            selectedProducts.removeAll()
                        }) {
                            HStack {
                                Image(systemName: "trash.fill")
                                    .foregroundColor(.red)
                                
                            }
                        }
                        Spacer()
                    }
                    .padding()
                    .background(Color.clear)
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 2) 
                }
            }
        }
        .environmentObject(viewModel)
    }
}

struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesView(viewModel: ProductViewModel())
  
    }
}
