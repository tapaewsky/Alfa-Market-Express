//
//  olacingAnOrder.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 29.09.2024.
//

import SwiftUI

struct CheckoutView: View {
    @ObservedObject var viewModel: MainViewModel
    
    @State private var comment: String = "" // Переменная для хранения комментария
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            VStack {
                selectedProductsList
                title
                storeInfo
                Spacer()
                commentSection
                Spacer()
                orderButton
                Spacer()
            }
            .padding()
        }
    }
    
    private var selectedProductsList: some View {
        ScrollView {
            VStack {
                ForEach(viewModel.cartViewModel.cartProduct.filter { viewModel.cartViewModel.selectedProducts[$0.id] == true }, id: \.id) { cartProduct in
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
                    .padding(.vertical, 1 )
                    .padding(.horizontal, 15)
                }
            }
        }
        .frame(maxHeight: 400)
    }
    
    private var title: some View {
        VStack {
            Text("Оформление заказа")
                .bold()
                .font(.title3)
        }
    }
    
    private var storeInfo: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(viewModel.profileViewModel.userProfile.storeName)
                .foregroundColor(.black)
                .font(.system(size: 15, weight: .light, design: .default))
            
            Text("Код магазина: \(viewModel.profileViewModel.userProfile.storeCode)")
                .foregroundColor(.black)
                .font(.system(size: 15, weight: .light, design: .default))
            
            HStack {
                Text("Адрес: ")
                    .foregroundColor(.black)
                    .font(.system(size: 15, weight: .light, design: .default))
                +
                Text(viewModel.profileViewModel.userProfile.storeAddress)
                    .foregroundColor(.black)
                    .font(.system(size: 15, weight: .light, design: .default))
            }
            
            HStack {
                Text("Телефон: \(viewModel.profileViewModel.userProfile.storePhoneNumber)")
                    .foregroundColor(.black)
                    .font(.system(size: 15, weight: .light, design: .default))
            }
            
            HStack {
                Text("\(selectedProductCount) товара")
                    .font(.title3)
                    .bold()
                    .foregroundColor(.black)
                
                Spacer()
                
                Text("\(Int(selectedTotalPrice)) ₽")
                    .foregroundColor(.colorRed)
                    .font(.title3)
                    .bold()
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 1)
    }
    
    private var commentSection: some View {
        VStack(alignment: .leading) {
            Text("Комментарий к заказу")
                .foregroundColor(.black)
                .font(.system(size: 20, weight: .regular, design: .default))
            
            TextField("Ваш комментарий", text: $comment)
                .padding()
                .background(Color.white)
                .overlay(RoundedRectangle(cornerRadius: 15).stroke(.colorGreen, lineWidth: 1))
        }
    }
    
    private var orderButton: some View {
        Button(action: {
            Task {
                let selectedProducts = viewModel.cartViewModel.cartProduct.filter {
                    viewModel.cartViewModel.selectedProducts[$0.id] == true
                }
                
                guard !selectedProducts.isEmpty else {
                    print("Нет выбранных продуктов для заказа.")
                    return
                }

                var orderItems: [OrderItem] = []
                
                do {
                    for product in selectedProducts {
                        let orderItem = viewModel.ordersViewModel.orderItemFromCartProduct(product)
                        orderItems.append(orderItem)
                    }
                    
                    if orderItems.isEmpty {
                        print("Ошибка: нет конвертированных товаров для заказа.")
                        return
                    }

                    let order = try await viewModel.ordersViewModel.createOrder(
                        items: orderItems,
                        comments: comment,
                        accessToken: viewModel.ordersViewModel.authManager.accessToken ?? ""
                    )
                    
                    print("Заказ успешно создан: \(order)")
                    
                } catch {
                    print("Ошибка при создании заказа: \(error.localizedDescription)")
                }
            }
        }) {
            Text("Заказать")
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.green)
                .cornerRadius(15)
                .foregroundColor(.white)
        }
    }
    
    private var selectedProductCount: Int {
        viewModel.cartViewModel.cartProduct.filter { viewModel.cartViewModel.selectedProducts[$0.id] == true }.count
    }
    
    private var selectedTotalPrice: Double {
        viewModel.cartViewModel.cartProduct
            .filter { viewModel.cartViewModel.selectedProducts[$0.id] == true }
            .reduce(0) { total, cartProduct in
                total + (Double(cartProduct.product.price) ?? 0)
            }
    }
}

struct CheckoutView_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutView(viewModel: MainViewModel())
    }
}
