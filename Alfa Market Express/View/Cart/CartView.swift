//
//  CartView.swift
//  WareHouse1
//
//  Created by Said Tapaev on 06.07.2024.
//
import SwiftUI

struct CartView: View {
    @ObservedObject var viewModel: MainViewModel
    @State private var selectAll: Bool = false
    @State private var isFetching = false
    @State private var isSelectionMode: Bool = false

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
        VStack(alignment: .leading) {
            HStack {
                Text(isSelectionMode ? "Выбрано: \(viewModel.cartViewModel.selectedProducts.filter { $0.value }.count)" : "Корзина")
                    .font(.headline)

                Spacer()

                Button(action: {
                    isSelectionMode.toggle()
                    selectAll.toggle()
                    viewModel.cartViewModel.selectAllProducts(selectAll)

                    if !isSelectionMode {
                        selectAll = false
                        viewModel.cartViewModel.clearSelection()
                    }
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
                    }) {
                        Text("Выбрать все")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Image(systemName: selectAll ? "square" : "checkmark.square")
                            .foregroundColor(selectAll ? .gray : .colorGreen)
                    }
                }
                .padding(.top, 5)
            }
        }
        .padding(.horizontal)
        .padding(.vertical)
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
                    product: cartProduct.product
                )
                .padding(.vertical, 1)
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

            Button(action: {
                handleCheckout()
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

    private func handleCheckout() {
        let selectedProductIds = viewModel.cartViewModel.selectedProducts.compactMap { $0.value ? $0.key : nil }
        let selectedProducts = viewModel.cartViewModel.cartProduct.filter { selectedProductIds.contains($0.id) }
        Task {
            await viewModel.cartViewModel.selectProductsForCheckout(products: selectedProducts)
        }
    }
}
