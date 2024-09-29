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
    @State private var isFavorite: Bool = false
    @State private var isAddedToCart: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            header
            
            ZStack {
                if viewModel.cartViewModel.cartProduct.isEmpty && !isFetching {
                    emptyCartView
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        cartItems
                    }
                    .frame(maxHeight: .infinity)
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
                    Text("Выбрано: \(viewModel.cartViewModel.selectedProducts.filter { $0.value }.count)")
                        .font(.headline)
                } else {
                    Text("Корзина   ")
                        .font(.headline) +
                    Text("\(Set(viewModel.cartViewModel.cartProduct.map { $0.product.id }).count)")
                        .font(.headline)
                        .foregroundColor(.gray) +
                    Text(" товаров")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
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
            
           
            if isSelectionMode {
                HStack {
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
                    
                    Spacer()
                    
                    Button(action: {
                        removeSelectedProduct()
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.colorGreen)
                    }
                }
            }
        }
        .padding()
    }
    
    private var emptyCartView: some View {
        Text("Корзина пуста")
            .padding()
            .foregroundColor(.gray)
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
            
            NavigationLink(destination: CheckoutView(viewModel: viewModel)) {
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
    
   

    
    // MARK: - Функции для работы с корзиной и избранным
    
    private func toggleCart(for product: Product) async {
        if isAddedToCart {
            await viewModel.cartViewModel.removeFromCart(product)
        } else {
            await viewModel.cartViewModel.addToCart(product, quantity: 1)
        }
        isAddedToCart.toggle()
    }
    
    private func toggleFavorite(for product: Product) async {
        await viewModel.favoritesViewModel.toggleFavorite(for: product)
        isFavorite = viewModel.favoritesViewModel.isFavorite(product)
    }
    
    // Загрузка корзины
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
    
    private func handleCheckout() {
        let selectedProductIds = viewModel.cartViewModel.selectedProducts.compactMap { $0.value ? $0.key : nil }
        let selectedProducts = viewModel.cartViewModel.cartProduct.filter { selectedProductIds.contains($0.id) }
        Task {
            await viewModel.cartViewModel.selectProductsForCheckout(products: selectedProducts)
        }
    }
    
    private func removeSelectedProduct() {
        let selectedProductIds = viewModel.cartViewModel.selectedProducts.compactMap { $0.value ? $0.key : nil }
        print("ID выбранных продуктов для удаления: \(selectedProductIds)")
        
        Task {
            for productId in selectedProductIds {
                print("Попытка удалить продукт с ID: \(productId)")
                
                // Проверяем, есть ли продукт в корзине
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


