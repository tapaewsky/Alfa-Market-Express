//
//  CartItemView.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 12.09.2024.
//
import SwiftUI
import Kingfisher

struct CartItemView: View {
    @ObservedObject var viewModel: CartViewModel
    @Binding var isSelected: Bool
    let product: Product
    @State private var quantity: Int
    @State private var totalPriceForProduct: Double
    @State private var isFavorite: Bool = false
    @State private var isAddedToCart: Bool = false

    var cartProduct: CartProduct

    init(cartProduct: CartProduct, viewModel: CartViewModel, isSelected: Binding<Bool>, product: Product) {
        self.cartProduct = cartProduct
        self._quantity = State(initialValue: cartProduct.quantity)
        self._totalPriceForProduct = State(initialValue: cartProduct.getTotalPrice)
        self.viewModel = viewModel
        self._isSelected = isSelected
        self.product = product
    }

    var body: some View {
        HStack {
            Button(action: {
                isSelected.toggle()
                viewModel.toggleProductSelection(cartProduct.product)
            }) {
                Image(systemName: isSelected ? "checkmark.square" : "square")
                    .foregroundColor(isSelected ? .green : .gray)
            }
            .buttonStyle(PlainButtonStyle())
            .contentShape(Circle())

            VStack {
                if let imageUrl = URL(string: cartProduct.product.imageUrl ?? "") {
                    KFImage(imageUrl)
                        .placeholder {
                            ProgressView()
                                .frame(width: 100, height: 100)
                        }
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .cornerRadius(8)
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .cornerRadius(10)
                        .clipped()
                }
                Spacer()

                HStack {
                    Button(action: {
                        if quantity > 1 {
                            quantity -= 1
                            updateQuantity()
                        }
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .foregroundColor(.gray)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .contentShape(Circle())

                    Text("\(quantity)")
                        .padding(.horizontal, 8)

                    Button(action: {
                        quantity += 1
                        updateQuantity()
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.green)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .contentShape(Circle())
                }
                .padding(.horizontal)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(cartProduct.product.name)
                    .font(.headline)
                    .lineLimit(2)

                Text("\(Int(totalPriceForProduct)) ₽")
                    .font(.subheadline)
                    .foregroundColor(.red)

                Text(cartProduct.product.description)
                    .font(.footnote)
                    .lineLimit(2)

                HStack {
                    Button(action: {
                        if isAddedToCart {
                            Task {
                                await viewModel.removeFromCart(product)
                            }
                        }
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .contentShape(Circle())

                    Button(action: {
                        isFavorite.toggle()
                        toggleFavorite(product)
                    }) {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .foregroundColor(isFavorite ? .red : .green)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .contentShape(Circle())
                }
                .padding(.top, 8)
            }
        }
        .padding(.vertical)
        .padding(.horizontal)
        .onAppear {
            calculateTotalPrice()
        }
    }

    private func calculateTotalPrice() {
        totalPriceForProduct = (Double(cartProduct.product.price) ?? 0) * Double(quantity)
    }

    private func updateQuantity() {
        Task {
            await viewModel.updateProductQuantity(cartProduct.product, newQuantity: quantity)
            calculateTotalPrice()
        }
    }

    private func toggleFavorite(_ product: Product) {
        Task {
            await viewModel.favoritesViewModel.toggleFavorite(for: product)
        }
    }
}
