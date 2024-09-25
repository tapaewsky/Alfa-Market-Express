//
//  CartView 2.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 22.09.2024.
//


import SwiftUI

struct CartView: View {
    @ObservedObject var viewModel: MainViewModel
    @State private var selectAll: Bool = false
    @State private var isFetching = false

    var body: some View {
        VStack {
            header
            ScrollView {
                if viewModel.cartViewModel.cartProduct.isEmpty && !isFetching {
                    emptyCartView
                } else {
                    cartItems
                }
            }
            footer
        }
        .onAppear {
            loadCart()
        }
    }

    private var header: some View {
        HStack {
            Text("\(viewModel.cartViewModel.cartProduct.count) Товаров")
                .font(.headline)
                .foregroundColor(.gray)

            Spacer()

            Text("Корзина")
                .font(.headline)

            Spacer()

            Button(action: {
                selectAll.toggle()
                viewModel.cartViewModel.selectAllProducts(selectAll)
            }) {
                Text(selectAll ? "Снять выбор" : "Выбрать все")
                    .font(.headline)
                    .foregroundColor(.colorGreen)
            }
        }
        .padding(.horizontal)
    }

    private var emptyCartView: some View {
        Text("Корзина пуста")
            .padding()
            .foregroundColor(.gray)
    }

    private var cartItems: some View {
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
                viewModel: viewModel.cartViewModel,
                isSelected: isSelected,
                product: cartProduct.product
            )
            .padding(.vertical, 6)
            .padding(.horizontal, 8)
        }
    }

    private var footer: some View {
        HStack {
            Text("\(Int(viewModel.cartViewModel.selectedTotalPrice)) ₽")
                .font(.callout)
                .bold()

            Spacer()

            Button(action: {
                // Действие при оформлении заказа
            }) {
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
}