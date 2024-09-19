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

    var body: some View {
        VStack {
            HStack {
                Text("\(viewModel.cartViewModel.cart.count) Товаров")
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

            List {
                ForEach(viewModel.cartViewModel.cart) { product in
                    let cartProduct = CartProduct(
                        id: product.id,
                        product: product,
                        quantity: product.quantity,
                        getTotalPrice: (Double(product.price) ?? 0) * Double(product.quantity)
                    )
                    
                    let isSelected = Binding<Bool>(
                        get: {
                            viewModel.cartViewModel.selectedProducts[product.id] ?? false
                        },
                        set: { newValue in
                            viewModel.cartViewModel.selectedProducts[product.id] = newValue
                            viewModel.cartViewModel.updateSelectedTotalPrice()
                        }
                    )

                    CartItemView(
                        cartProduct: cartProduct,
                        viewModel: viewModel.cartViewModel,
                        isSelected: isSelected
                    )
                }
            }
            .onAppear {
                Task {
                    await viewModel.cartViewModel.fetchCartData()
                }
            }

            HStack {
                Text("\(Int(viewModel.cartViewModel.selectedTotalPrice)) ₽")
                    .font(.callout)
                    .bold()
                
                Spacer()
                
                Button(action: {
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
    }
}
