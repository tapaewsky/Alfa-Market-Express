//
//  CartMainView.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 27.09.2024.
//

import SwiftUI

struct CartMainView: View {
    @ObservedObject var viewModel: MainViewModel
    @State private var selectAll: Bool = false
    @State private var isFetching = false
    @State private var isSelectionMode: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            header
            
            ZStack {
                if viewModel.cartViewModel.cartProduct.isEmpty && !isFetching {
                    emptyCartView
                } else {
                    cartContent
                }
            }
            .frame(maxHeight: .infinity)
            
            footer
        }
        .padding(0)
        .onAppear {
            loadCart()
        }
    }

    private var header: some View {
        VStack {
            HStack {
                if isSelectionMode {
                    selectionCountView
                } else {
                    cartCountView
                }
                Spacer()
                selectionButton
            }
            if isSelectionMode {
                selectionControls
            }
        }
        .padding()
    }
    
    private var selectionCountView: some View {
        Text("Выбрано: \(viewModel.cartViewModel.selectedProducts.filter { $0.value }.count)")
            .font(.headline)
    }
    
    private var cartCountView: some View {
        Text("Корзина   ")
            .font(.headline) +
        Text("\(Set(viewModel.cartViewModel.cartProduct.map { $0.product.id }).count)")
            .font(.headline)
            .foregroundColor(.gray) +
        Text(" товаров")
            .font(.headline)
            .foregroundColor(.gray)
    }
    
    private var selectionButton: some View {
        Button(action: {
            isSelectionMode.toggle()
            selectAll = false
            viewModel.cartViewModel.clearSelection()
            viewModel.cartViewModel.selectAllProducts(selectAll)
        }) {
            Text(isSelectionMode ? "Отменить" : "Выбрать")
                .font(.headline)
                .foregroundColor(.colorGreen)
        }
    }
    
    private var selectionControls: some View {
        HStack {
            selectAllButton
            
            Spacer()
            
            removeButton
        }
    }
    
    private var selectAllButton: some View {
        Button(action: {
            selectAll.toggle()
            viewModel.cartViewModel.selectAllProducts(selectAll)
            viewModel.cartViewModel.cartProduct.forEach { product in
                viewModel.cartViewModel.selectedProducts[product.id] = selectAll
            }
        }) {
            Image(systemName: selectAll ? "checkmark.square" : "square")
                .foregroundColor(selectAll ? .colorGreen : .gray)
            Text("Выбрать все (\(viewModel.cartViewModel.selectedProducts.filter { $0.value }.count))")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
    
    private var removeButton: some View {
        Button(action: {
            removeSelectedProduct()
        }) {
            Image(systemName: "trash")
                .foregroundColor(.colorGreen)
        }
    }
    
    private var emptyCartView: some View {
        Text("Корзина пуста")
            .padding()
            .foregroundColor(.gray)
    }
    
    private var cartContent: some View {
        ScrollView(.vertical, showsIndicators: false) {
            cartItems
        }
        .frame(maxHeight: .infinity)
    }
    
    private var cartItems: some View {
        VStack {
            ForEach(viewModel.cartViewModel.cartProduct, id: \.id) { cartProduct in
                let isSelected = Binding<Bool>(
                    get: {
                        viewModel.cartViewModel.selectedProducts[cartProduct.id] ?? false
                    },
                    set: { newValue in
                        viewModel.cartViewModel.selectedProducts[cartProduct.id] = newValue
                        viewModel.cartViewModel.updateSelectedTotalPrice()
                    }
                )
                
                CartItemView(
                    cartProduct: cartProduct,
                    viewModel: viewModel,
                    product: cartProduct.product,
                    isSelected: isSelected
                )
                .padding(.vertical, 2)
                .padding(.horizontal, 15)
                .environment(\.isSelectionMode, isSelectionMode)
            }
        }
    }
    
    private var footer: some View {
        HStack {
            Text("\(Int(viewModel.cartViewModel.selectedTotalPrice)) ₽")
                .font(.callout)
                .bold()
            
            Spacer()
            
            NavigationLink(
                destination: CheckoutView(viewModel: viewModel)
            ) {
                Text("Оформить заказ")
                    .font(.callout)
                    .padding(10)
                    .background(Color.colorGreen)
                    .foregroundColor(.white)
                    .cornerRadius(17)
            }
        }
        .padding()
    }

    private func loadCart() {
        isFetching = true
        viewModel.cartViewModel.fetchCart { success in
            DispatchQueue.main.async {
                isFetching = false
                if success {
                    print("Корзина успешно загружена")
                } else {
                    print("Не удалось загрузить корзину")
                }
            }
        }
    }
    
    private func removeSelectedProduct() {
        let selectedProductIds = viewModel.cartViewModel.selectedProducts.compactMap { $0.value ? $0.key : nil }
        print("ID выбранных продуктов для удаления: \(selectedProductIds)")
        
        Task {
            for productId in selectedProductIds {
                if let productToRemove = viewModel.cartViewModel.cartProduct.first(where: { $0.product.id == productId }) {
                    await viewModel.cartViewModel.removeFromCart(productToRemove.product)
                    print("Продукт с ID: \(productToRemove.product.id) успешно удален из корзины")
                } else {
                    print("Продукт с ID \(productId) не найден в корзине")
                }
            }
            viewModel.cartViewModel.clearSelection()
        }
    }
}
