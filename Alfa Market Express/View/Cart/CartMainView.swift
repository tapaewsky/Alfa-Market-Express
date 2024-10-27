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
        .onAppear { loadCart() }
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }

    private var header: some View {
        HStack {
            if isSelectionMode {
                Text("Выбрано: \(viewModel.cartViewModel.selectedProducts.filter { $0.value }.count)")
                    .font(.headline)
            } else {
                HStack {
                    Text("Корзина   ").font(.headline) +
                    Text("\(viewModel.cartViewModel.cartProduct.count)").font(.headline).foregroundColor(.gray) +
                    Text(" товаров").font(.headline).foregroundColor(.gray)
                }
            }
            Spacer()
            selectionButton
        }
        .padding()
    }

    private var selectionButton: some View {
        Button(action: toggleSelectionMode) {
            Text(isSelectionMode ? "Отменить" : "Выбрать")
                .font(.headline)
                .foregroundColor(.colorGreen)
        }
    }

    private var cartContent: some View {
        ZStack {
            if viewModel.cartViewModel.cartProduct.isEmpty && !isFetching {
                Text("Корзина пуста")
                    .padding()
                    .foregroundColor(.gray)
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack {
                        ForEach(viewModel.cartViewModel.cartProduct, id: \.id) { cartProduct in
                            cartItemRow(for: cartProduct)
                        }
                    }
                }
                .frame(maxHeight: .infinity)
            }
        }
        .frame(maxHeight: .infinity)
    }

    private func cartItemRow(for cartProduct: CartProduct) -> some View {
        let isSelected = Binding<Bool>(
            get: { viewModel.cartViewModel.selectedProducts[cartProduct.id] ?? false },
            set: { newValue in
                viewModel.cartViewModel.selectedProducts[cartProduct.id] = newValue
                viewModel.cartViewModel.updateSelectedTotalPrice()
            }
        )

        return CartItemView(
            cartProduct: cartProduct,
            viewModel: viewModel,
            isSelected: isSelected,
            onCartUpdated: { viewModel.cartViewModel.updateTotalPrice() }
        )
        .padding(.vertical, 2)
        .padding(.horizontal, 15)
    }

    private var footer: some View {
        HStack {
            let totalPrice = isSelectionMode ? viewModel.cartViewModel.selectedTotalPrice : viewModel.cartViewModel.totalPrice

            Text("\(Int(totalPrice)) ₽")
                .font(.callout)
                .bold()
            
            Spacer()

            NavigationLink(
                destination: CheckoutView(
                    viewModel: viewModel,
                    selectedTab: $selectedTab,
                    products: selectedOrAllProducts(),
                    totalPrice: totalPrice,
                    productCount: selectedOrAllProducts().count
                )
            ) {
                Text("Оформить заказ")
                    .font(.callout)
                    .padding(10)
                    .background(Color.colorGreen)
                    .foregroundColor(.white)
                    .cornerRadius(15)
            }
        }
        .padding()
        .background(.white)
        .shadow(radius: 10)
        .cornerRadius(10)
       
        .onChange(of: viewModel.cartViewModel.selectedTotalPrice) { newValue in
            
        }
    }

    private func loadCart() {
        isFetching = true
        viewModel.cartViewModel.fetchCart { success in
            DispatchQueue.main.async {
                isFetching = false
                if success {
                    viewModel.cartViewModel.updateTotalPrice()
                } else {
                    print("Не удалось загрузить корзину")
                }
            }
        }
    }

    private func selectedOrAllProducts() -> [Product] {
        let selectedProducts = viewModel.cartViewModel.cartProduct.filter {
            viewModel.cartViewModel.selectedProducts[$0.id] == true
        }
        return selectedProducts.isEmpty
            ? viewModel.cartViewModel.cartProduct.map { $0.product }
            : selectedProducts.map { $0.product }
    }

    private func toggleSelectionMode() {
        isSelectionMode.toggle()
        viewModel.cartViewModel.clearSelection()
    }
}

// MARK: - Preview

struct CartMainView_Previews: PreviewProvider {
    static var previews: some View {
        CartMainView(viewModel: MainViewModel())
    }
}
