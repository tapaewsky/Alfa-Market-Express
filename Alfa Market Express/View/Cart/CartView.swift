//
//  CartView.swift
//  WareHouse1
//
//  Created by Said Tapaev on 06.07.2024.
//
import SwiftUI

struct CartView: View {
    @ObservedObject var viewModel: CartViewModel
    @ObservedObject var favoritesViewModel: FavoritesViewModel
    @State private var selectAll: Bool = false

    var body: some View {
        VStack {
            HStack {
                Text("\(viewModel.cart.count) Товаров")
                    .font(.headline)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Text("Корзина")
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
                    selectAll.toggle()
                    viewModel.selectAllProducts(selectAll)
                }) {
                    Text(selectAll ? "Снять выбор" : "Выбрать все")
                        .font(.headline)
                        .foregroundColor(.colorGreen)
                }
            }
            .padding(.horizontal)

            List {
                ForEach(viewModel.cart) { product in
                    let cartProduct = CartProduct(
                        id: product.id,
                        product: product,
                        quantity: product.quantity,
                        getTotalPrice: (Double(product.price) ?? 0) * Double(product.quantity)
                    )
                    
                    let isSelected = Binding<Bool>(
                        get: {
                            viewModel.selectedProducts[product.id] ?? false
                        },
                        set: { newValue in
                            viewModel.selectedProducts[product.id] = newValue
                            viewModel.updateSelectedTotalPrice()
                        }
                    )

                    CartItemView(
                        cartProduct: cartProduct,
                        viewModel: viewModel,
                        favoritesViewModel: favoritesViewModel,
                        isSelected: isSelected
                    )
                }
            }

            HStack {
                Text("\(Int(viewModel.selectedTotalPrice)) ₽")
                    .font(.callout)
                    .bold()
                
                Spacer()
                
                Button(action: {
                    // Оформить заказ
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
