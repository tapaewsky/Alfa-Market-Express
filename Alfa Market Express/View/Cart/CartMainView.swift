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
    @State private var selectedTab: Int = 0

    var body: some View {
        VStack(spacing: 0) {
            header
            cartContent
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
                SelectionCountView(selectedCount: viewModel.cartViewModel.selectedProducts.filter { $0.value }.count)
            } else {
                CartCountView(count: viewModel.cartViewModel.cartProduct.count)
            }
            Spacer()
            selectionButton
        }
        .padding()
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

    private var cartContent: some View {
        ZStack {
            if viewModel.cartViewModel.cartProduct.isEmpty && !isFetching {
                EmptyCartView()
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    cartItems
                }
                .frame(maxHeight: .infinity)
            }
        }
        .frame(maxHeight: .infinity)
    }

    private var cartItems: some View {
        VStack {
            ForEach(viewModel.cartViewModel.cartProduct, id: \.id) { cartProduct in
                CartItemRow(
                    cartProduct: cartProduct,
                    viewModel: viewModel,
                    isSelectionMode: $isSelectionMode
                )
            }
        }
    }

    private var footer: some View {
        HStack {
            let totalPrice = isSelectionMode ? viewModel.cartViewModel.selectedTotalPrice : viewModel.cartViewModel.totalPrice
            TotalPriceView(totalPrice: totalPrice)
            Spacer()
            CheckoutButton(viewModel: viewModel, selectedTab: $selectedTab, selectedOrAllProducts: selectedOrAllProducts)
        }
        .padding()
        .onChange(of: viewModel.cartViewModel.selectedTotalPrice) { newValue in
            print("Общая цена выбранных продуктов: \(Int(newValue)) ₽")
        }
    }

    private func loadCart() {
        isFetching = true
        viewModel.cartViewModel.fetchCart { success in
            DispatchQueue.main.async {
                isFetching = false
                if success {
                    print("Корзина успешно загружена")
                    viewModel.cartViewModel.updateTotalPrice()
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
        viewModel.cartViewModel.clearSelection()
    }
}

// MARK: - Subviews

struct EmptyCartView: View {
    var body: some View {
        Text("Корзина пуста")
            .padding()
            .foregroundColor(.gray)
    }
}

struct SelectionCountView: View {
    let selectedCount: Int

    var body: some View {
        Text("Выбрано: \(selectedCount)")
            .font(.headline)
    }
}

struct CartCountView: View {
    let count: Int

    var body: some View {
        Text("Корзина   ")
            .font(.headline) +
        Text("\(count)")
            .font(.headline)
            .foregroundColor(.gray) +
        Text(" товаров")
            .font(.headline)
            .foregroundColor(.gray)
    }
}

struct TotalPriceView: View {
    let totalPrice: Double

    var body: some View {
        Text("\(Int(totalPrice)) ₽")
            .font(.callout)
            .bold()
    }
}

struct CheckoutButton: View {
    @ObservedObject var viewModel: MainViewModel
    @Binding var selectedTab: Int
    var selectedOrAllProducts: () -> [Product]

    var body: some View {
        NavigationLink(
            destination: CheckoutView(viewModel: viewModel, selectedTab: $selectedTab, products: selectedOrAllProducts())
        ) {
            Text("Оформить заказ")
                .font(.callout)
                .padding(10)
                .background(Color.colorGreen)
                .foregroundColor(.white)
                .cornerRadius(17)
        }
    }
}

// MARK: - CartItemRow

struct CartItemRow: View {
    let cartProduct: CartProduct
    @ObservedObject var viewModel: MainViewModel
    @Binding var isSelectionMode: Bool

    var body: some View {
        let isSelected = Binding<Bool>(
            get: { viewModel.cartViewModel.selectedProducts[cartProduct.id] ?? false },
            set: { newValue in
                viewModel.cartViewModel.selectedProducts[cartProduct.id] = newValue
                viewModel.cartViewModel.updateSelectedTotalPrice()
                print("Текущая цена для выбранных продуктов: \(Int(viewModel.cartViewModel.selectedTotalPrice)) ₽")
            }
        )

        CartItemView(
            cartProduct: cartProduct,
            viewModel: viewModel,
            isSelected: isSelected,
            onCartUpdated: {
                viewModel.cartViewModel.updateTotalPrice()
            }
        )
        .padding(.vertical, 2)
        .padding(.horizontal, 15)
        .environment(\.isSelectionMode, isSelectionMode)
    }
}

// MARK: - Preview

struct CartMainView_Previews: PreviewProvider {
    static var previews: some View {
        CartMainView(viewModel: MainViewModel())
    }
}
