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
    
    var body: some View {
        VStack {
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
            
            ScrollView {
                if viewModel.cartViewModel.cartProduct.isEmpty && !isFetching {
                    Text("Корзина пуста")
                        .padding()
                        .foregroundColor(.gray)
                } else {
                    ForEach(viewModel.cartViewModel.cartProduct, id: \.id) { cartProduct in
                        CartItemView(cartProduct: cartProduct, viewModel: viewModel.cartViewModel, isSelected: .constant(false), product: cartProduct.product)
                                               .padding(.vertical, 6)
                                               .padding(.horizontal, 8)
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
            }
            
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
        .onAppear {
            loadCart()
        }
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
