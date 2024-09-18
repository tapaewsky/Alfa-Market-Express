//
//  CartItemView.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 12.09.2024.
//
import SwiftUI
import Kingfisher

struct CartItemView: View {
    let cartProduct: CartProduct
    @ObservedObject var viewModel: CartViewModel
    @ObservedObject var favoritesViewModel: FavoritesViewModel
    @Binding var isSelected: Bool
    
    @State private var quantity: Int
    @State private var totalPriceForProduct: Double
    @State private var isFavorite: Bool = false

    init(cartProduct: CartProduct, viewModel: CartViewModel, favoritesViewModel: FavoritesViewModel, isSelected: Binding<Bool>) {
        self.cartProduct = cartProduct
        self._quantity = State(initialValue: cartProduct.quantity)
        self._totalPriceForProduct = State(initialValue: cartProduct.getTotalPrice)
        self.viewModel = viewModel
        self.favoritesViewModel = favoritesViewModel
        self._isSelected = isSelected
    }
    
    var body: some View {
        HStack {
            
            Button(action: {
                isSelected.toggle()
                viewModel.toggleProductSelection(cartProduct.product)
            }) {
                Image(systemName: isSelected ? "checkmark.square" : "square")
                    .foregroundColor(isSelected ? .colorGreen : .gray)
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
                            Task {
                                await updateQuantity(newQuantity: quantity - 1)
                            }
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
                        Task {
                            await updateQuantity(newQuantity: quantity + 1)
                        }
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.colorGreen)
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
                    .foregroundColor(.colorRed)
                
                Text(cartProduct.product.description)
                    .font(.footnote)
                    .lineLimit(2)
                
               
                HStack {
                    Button(action: {
                        Task {
                            await removeFromCart()
                        }
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.colorRed)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .contentShape(Circle())
                    
                    Button(action: {
                        isFavorite.toggle()
                        if isFavorite {
                            favoritesViewModel.addToFavorites(cartProduct.product)
                        } else {
                            favoritesViewModel.removeFromFavorites(cartProduct.product)
                        }
                    }) {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .foregroundColor(isFavorite ? .colorRed : .colorGreen)
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
            isFavorite = favoritesViewModel.isFavorite(cartProduct.product)
        }
    }
    
    private func calculateTotalPrice() {
        totalPriceForProduct = (Double(cartProduct.product.price) ?? 0) * Double(quantity)
    }

    private func updateQuantity(newQuantity: Int) async {
        do {
          
            await viewModel.updateProductQuantity(cartProduct.product, newQuantity: newQuantity)
            self.quantity = newQuantity
            calculateTotalPrice()
        } catch {
            print("Ошибка при обновлении количества товара")
        }
    }

    private func removeFromCart() async {
        do {
          
            await viewModel.removeFromCart(cartProduct.product)
        } catch {
            print("Ошибка при удалении товара из корзины")
        }
    }
}
