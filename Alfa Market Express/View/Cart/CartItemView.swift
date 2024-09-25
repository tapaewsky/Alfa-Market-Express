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
    let product: Product
    @State private var quantity: Int
    @State private var totalPriceForProduct: Double
    
    var cartProduct: CartProduct
    @State private var isSelected: Bool = false 
    
    @Environment(\.isSelectionMode) var isSelectionMode
    
    init(cartProduct: CartProduct, viewModel: MainViewModel, product: Product) {
        self.cartProduct = cartProduct
        self._quantity = State(initialValue: cartProduct.quantity)
        self._totalPriceForProduct = State(initialValue: cartProduct.getTotalPrice)
        self.viewModel = viewModel
        self.product = product
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.white)
                .shadow(radius: 2)
            
            HStack {
                productImage
                NavigationLink(destination: ProductDetailView(viewModel: viewModel, product: product)) {
                    productDetails
                }
               
            }
            .padding(.vertical)
            .onChange(of: quantity) { newValue in
                updateQuantity()
            }
        }
    }
    
    private var productImage: some View {
        ZStack(alignment: .topLeading) {
            if let imageUrl = URL(string: cartProduct.product.imageUrl ?? "") {
                KFImage(imageUrl)
                    .placeholder {
                        ProgressView()
                            .frame(width: 108, height: 140)
                    }
                    .resizable()
                    .scaledToFit()
                    .frame(width: 115, height: 140)
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 115, height: 140)
                    .clipped()
            }
            
            if isSelectionMode {
                Button(action: {
                    isSelected.toggle()
                    viewModel.cartViewModel.toggleProductSelection(cartProduct.product)
                }) {
                    Image(systemName: isSelected ? "checkmark.square" : "square")
                        .foregroundColor(isSelected ? .colorGreen : .gray)
                        .padding(8)
                }
                .buttonStyle(PlainButtonStyle())
            }
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
            Button(action: decreaseQuantity) {
                Image(systemName: "minus")
                    .foregroundColor(.black)
            }
            .buttonStyle(PlainButtonStyle())
            .contentShape(Circle())
            
            Text("\(quantity)")
                .padding(.horizontal, 5)
                .foregroundColor(.black)
            
            Button(action: increaseQuantity) {
                Image(systemName: "plus")
                    .foregroundColor(.black)
            }
            .buttonStyle(PlainButtonStyle())
            .contentShape(Circle())
        }
        .padding(7)
        .background(.colorGray)
        .cornerRadius(15)
    }
    
    private func calculateTotalPrice() {
        totalPriceForProduct = (Double(cartProduct.product.price) ?? 0) * Double(quantity)
    }
    
    private func increaseQuantity() {
        quantity += 1
        updateQuantity()
    }
    
    private func decreaseQuantity() {
        if quantity > 1 {
            quantity -= 1
            updateQuantity()
        }
    }
    
    private func updateQuantity() {
        Task {
            await viewModel.cartViewModel.updateProductQuantity(cartProduct.product, newQuantity: quantity)
            calculateTotalPrice()
        }
    }
    
   
    
}

