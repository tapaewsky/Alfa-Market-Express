//
//  CartMainView.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 27.09.2024.
//

import SwiftUI

struct CartMainView: View {
    @ObservedObject var viewModel: MainViewModel
    @State private var isFetching = false
    @State private var isSelectionMode: Bool = false
    @State private var selectAll: Bool = false
    
    

    var body: some View {
        VStack {
            header
            content
            footer
        }
        .padding()
        .onAppear(perform: loadCart)
    }
    
    private var header: some View {
        VStack {
            HStack {
                Text(isSelectionMode ? "Выбрано: \(viewModel.cartViewModel.selectedProducts.filter { $0.value }.count)" : "Корзина \(Set(viewModel.cartViewModel.cartProduct.map { $0.product.id }).count) товаров")
                    .font(.headline)
                
                Spacer()
                
                Button(action: toggleSelectionMode) {
                    Text(isSelectionMode ? "Отменить" : "Выбрать")
                        .font(.headline)
                        .foregroundColor(.colorGreen)
                }
            }
            
            if isSelectionMode {
                selectionControls
            }
        }
    }

    private var selectionControls: some View {
        HStack {
            Button(action: toggleSelectAll) {
                Image(systemName: selectAll ? "checkmark.square" : "square")
                    .foregroundColor(selectAll ? .colorGreen : .gray)
                Text("Выбрать все (\(viewModel.cartViewModel.selectedProducts.filter { $0.value }.count))")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
    }

    private var content: some View {
        ZStack {
            if viewModel.cartViewModel.cartProduct.isEmpty && !isFetching {
                Text("Корзина пуста").padding().foregroundColor(.gray)
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    ForEach(viewModel.cartViewModel.cartProduct, id: \.id) { cartProduct in
                        let isSelected = Binding<Bool>(
                            get: { viewModel.cartViewModel.selectedProducts[cartProduct.id] ?? false },
                            set: { newValue in
                                viewModel.cartViewModel.selectedProducts[cartProduct.id] = newValue
                                viewModel.cartViewModel.updateSelectedTotalPrice()
                            }
                        )

                        CartItemView(cartProduct: cartProduct, viewModel: viewModel, product: cartProduct.product, isSelected: isSelected)
                            .padding(.vertical, 2)
                            .padding(.horizontal, 10)
                            .environment(\.isSelectionMode, isSelectionMode)
                    }
                }
                .frame(maxHeight: .infinity)
            }
        }
    }

    private var footer: some View {
        HStack {
            Text("\(Int(viewModel.cartViewModel.selectedTotalPrice)) ₽").font(.callout).bold()
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
        .background(Color.white)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(lineWidth: 1).shadow(radius: 5))
        .ignoresSafeArea()
    }
    
    private func loadCart() {
        isFetching = true
        viewModel.cartViewModel.fetchCart { success in
            DispatchQueue.main.async {
                isFetching = false
                print(success ? "Корзина успешно загружена" : "Не удалось загрузить корзину")
            }
        }
    }

    private func toggleSelectionMode() {
        isSelectionMode.toggle()
        selectAll = false
        viewModel.cartViewModel.clearSelection()
        viewModel.cartViewModel.selectAllProducts(selectAll)
    }

    private func toggleSelectAll() {
        selectAll.toggle()
        viewModel.cartViewModel.selectAllProducts(selectAll)
        viewModel.cartViewModel.cartProduct.forEach { product in
            viewModel.cartViewModel.selectedProducts[product.id] = selectAll
        }
    }
}
