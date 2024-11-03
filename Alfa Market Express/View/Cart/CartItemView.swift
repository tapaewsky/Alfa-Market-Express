//
//  CartItemView.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 12.09.2024.
//

import SwiftUI
import Kingfisher

struct CartItemView: View {
    @ObservedObject var viewModel: MainViewModel
    var cartProduct: CartProduct
    @State private var quantity: Int
    @State private var totalPriceForProduct: Double
    @Binding var isSelected: Bool
    var onCartUpdated: () -> Void
    let isSelectionMode: Bool
    var onTotalPriceUpdated: () -> Void
    
    init(cartProduct: CartProduct, viewModel: MainViewModel, isSelected: Binding<Bool>, onCartUpdated: @escaping () -> Void, onTotalPriceUpdated: @escaping () -> Void, isSelectionMode: Bool) {
        self.cartProduct = cartProduct
        self.viewModel = viewModel
        self._quantity = State(initialValue: cartProduct.quantity)
        self._totalPriceForProduct = State(initialValue: cartProduct.getTotalPrice)
        self.onCartUpdated = onCartUpdated
        self._isSelected = isSelected
        self.isSelectionMode = isSelectionMode
        self.onTotalPriceUpdated = onTotalPriceUpdated // Теперь это правильно
    }
    
    var body: some View {
        ZStack {
            background
            HStack {
                productImage
                NavigationLink(destination: ProductDetailView(viewModel: viewModel, product: cartProduct.product)) {
                    productDetails
                }
                Spacer()
                deleteButton
            }
        }
        .onChange(of: quantity) { newValue in
            if newValue < 1 {
                quantity = 1
            } else if newValue > 1000 {
                quantity = 1000
            }
            Task { await calculateTotalPrice() }
            onTotalPriceUpdated()
        }
        
        .onAppear {
                    Task {
                        await updateSelection()
                    }
                }
            }
            
    
  
    
    private var background: some View {
        RoundedRectangle(cornerRadius: 15)
            .fill(Color.white)
            .shadow(radius: 2)
    }
    
    private var productImage: some View {
        ZStack(alignment: .topLeading) {
            loadImage()
            
            if isSelectionMode {
                selectButton
            }
        }
    }
    
    private func loadImage() -> some View {
        if let imageUrl = URL(string: cartProduct.product.imageUrl ?? "") {
            return AnyView(
                KFImage(imageUrl)
                    .placeholder { ProgressView() }
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: 115, maxHeight: 150)
                    .cornerRadius(15)
            )
        } else {
            return AnyView(
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: 115, maxHeight: 150)
            )
        }
    }
    
    private var productDetails: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(cartProduct.product.name)
                .font(.headline)
                .lineLimit(1)
                .foregroundColor(.black)
            
            Text("\(Int(totalPriceForProduct)) ₽")
                .font(.subheadline)
                .foregroundColor(.colorRed)
            
            Text(cartProduct.product.description)
                .font(.footnote)
                .lineLimit(2)
                .foregroundColor(.black)
            
            quantityControl
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var quantityControl: some View {
        HStack {
            controlButton(systemName: "minus") {
                Task { await decreaseQuantity() }
            }
            .frame(width: 30, height: 30)

            TextField("", value: $quantity, formatter: NumberFormatter())
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .frame(width: 40)
                .padding(5)
                .cornerRadius(5)
                .onChange(of: quantity) { newValue in
                    if newValue < 1 {
                        quantity = 1
                    } else if newValue > 1000 {
                        quantity = 1000
                    }
                    Task { await updateQuantity() } // Добавьте этот вызов
                }

            controlButton(systemName: "plus") {
                Task { await increaseQuantity() }
            }
            .frame(width: 30, height: 30)
        }
        .padding(5)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(15)
    }
    
    private var deleteButton: some View {
        VStack {
            Button(action: { Task { await toggleCart() } }) {
                Image(systemName: "trash")
                    .foregroundColor(.colorGreen)
                    .padding()
            }
        }
    }
    
    private var selectButton: some View {
        Button(action: {
            Task {
                await toggleSelection()
                isSelected.toggle()
            }
        }) {
            Image(systemName: isSelected ? "checkmark.square" : "square")
                .foregroundColor(isSelected ? .colorGreen : .gray)
                .padding(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
    

    
    private func controlButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: { Task { await action() } }) {
            Image(systemName: systemName)
                .foregroundColor(.black)
                .frame(width: 30, height: 30)
                .contentShape(Circle())
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func increaseQuantity() async {
        quantity += 1
   
    }
    
    private func decreaseQuantity() async {
        if quantity > 1 {
            quantity -= 1

        }
    }
    
    private func updateQuantity() async {
        await viewModel.cartViewModel.updateProductQuantity(productId: cartProduct.id, newQuantity: quantity)
        await calculateTotalPrice() // Эта функция должна обновлять totalPriceForProduct
        onCartUpdated()
        onTotalPriceUpdated() // Убедитесь, что это вызывается после обновления
        print("Updated quantity for product \(cartProduct.product.name) to \(quantity)")
    }
  
    
    private func calculateTotalPrice() async {
        totalPriceForProduct = (Double(cartProduct.product.price) ?? 0) * Double(quantity)
        print("Calculated total price for product \(cartProduct.product.name): \(totalPriceForProduct)")
        onTotalPriceUpdated() // Убедитесь, что это вызывается после обновления
    }
    
    private func toggleSelection() async {
        viewModel.cartViewModel.selectedProducts[cartProduct.id] = isSelected
        if isSelected {
            viewModel.cartViewModel.selectProduct(cartProduct)
        } else {
            viewModel.cartViewModel.deselectProduct(cartProduct)
        }
        viewModel.cartViewModel.updateSelectedTotalPrice()
    }
    
    private func updateSelection() async {
        isSelected = viewModel.cartViewModel.selectedProducts[cartProduct.id] ?? false
    }
    
    private func toggleCart() async {
        await viewModel.cartViewModel.removeFromCart(productId: cartProduct.id)
        onCartUpdated()
    }
}
