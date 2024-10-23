//
//  CartMainView.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 27.09.2024.
//

import SwiftUI
import Kingfisher

struct CartMainView: View {
    @StateObject var viewModel: MainViewModel
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
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }

    private var header: some View {
        HStack {
            if isSelectionMode {
                selectionCountView
            } else {
                cartCountView
            }
            Spacer()
            selectionButton
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
        Text("\(viewModel.cartViewModel.cartProduct.count)")
            .font(.headline)
            .foregroundColor(.gray) +
        Text(" товаров")
            .font(.headline)
            .foregroundColor(.gray)
    }

    private var selectionButton: some View {
        Button(action: {
            toggleSelectionMode()
        }) {
            Text(isSelectionMode ? "Отменить" : "Выбрать")
                .font(.headline)
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
                    get: { viewModel.cartViewModel.selectedProducts[cartProduct.id] ?? false },
                    set: { newValue in
                        viewModel.cartViewModel.selectedProducts[cartProduct.id] = newValue
                        viewModel.cartViewModel.updateSelectedTotalPrice() // Обновляем общую цену при изменении выбора
                    }
                )
                
                CartItemView(
                    cartProduct: cartProduct,
                    viewModel: viewModel,
                    isSelected: isSelected,
                    onCartUpdated: {
                        viewModel.cartViewModel.updateTotalPrice() // Обновляем цену при изменении
                    }
                )
                .padding(.vertical, 2)
                .padding(.horizontal, 15)
                .environment(\.isSelectionMode, isSelectionMode)
            }
        }
    }

    private var footer: some View {
        HStack {
            let totalPrice = isSelectionMode ? viewModel.cartViewModel.selectedTotalPrice : viewModel.cartViewModel.totalPrice
            Text("\(Int(totalPrice)) ₽")
                .font(.callout)
                .bold()
            
            Spacer()
            
            NavigationLink(
                destination: CheckoutView(viewModel: viewModel, products: selectedOrAllProducts())
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
                    viewModel.cartViewModel.updateTotalPrice() // Обновляем цену после загрузки
                } else {
                    print("Не удалось загрузить корзину")
                }
            }
        }
    }

    private func selectedOrAllProducts() -> [Product] {
        let selectedProducts = viewModel.cartViewModel.cartProduct.filter { viewModel.cartViewModel.selectedProducts[$0.id] == true }
        return selectedProducts.isEmpty
            ? viewModel.cartViewModel.cartProduct.map { $0.product }
            : selectedProducts.map { $0.product }
    }

    private func toggleSelectionMode() {
        isSelectionMode.toggle()
        viewModel.cartViewModel.clearSelection() // Сбрасываем выбор при переходе в режим выбора
    }
}
