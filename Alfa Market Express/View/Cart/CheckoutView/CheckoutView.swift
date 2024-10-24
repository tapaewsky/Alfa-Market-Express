//
//  olacingAnOrder.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 29.09.2024.
//

import SwiftUI

struct CheckoutView: View {
    @ObservedObject var viewModel: MainViewModel
    @State private var showSuccessView = false
    @State private var comment: String = ""
    var products: [Product]
    @Environment(\.presentationMode) var presentationMode


    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            VStack {
                selectedProductsList
                VStack {
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
            .navigationBarItems(leading: CustomBackButton(label: "Назад", color: .colorGreen) {
                self.presentationMode.wrappedValue.dismiss()
            })
        }
        .onAppear {
            viewModel.profileViewModel.fetchUserProfile(completion: { _ in })
        }
     
        .navigationBarBackButtonHidden(true)
    }

    private var selectedProductsList: some View {
        ScrollView {
            VStack {
                let selectedProducts = viewModel.cartViewModel.cartProduct.filter { viewModel.cartViewModel.selectedProducts[$0.id] == true }
                let productsToShow = selectedProducts.isEmpty ? viewModel.cartViewModel.cartProduct : selectedProducts
                
                ForEach(productsToShow, id: \.id) { cartProduct in
                    let isSelected = Binding<Bool>(
                        get: {
                            viewModel.cartViewModel.selectedProducts[cartProduct.id] ?? false
                        },
                        set: { newValue in
                            // Обновление значения в selectedProducts
                            viewModel.cartViewModel.selectedProducts[cartProduct.id] = newValue
                            print("Установлено isSelected для \(cartProduct.product.name): \(newValue)")
                            viewModel.cartViewModel.updateSelectedTotalPrice()
                        }
                    )
                    
                    CartItemCheckout(cartProduct: Binding<CartProduct>(
                           get: { cartProduct },
                           set: { newValue in }
                       ))
                       .padding(.vertical, 2)
                       .padding(.horizontal, 15)
                   
                }
            }
        }
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
                .font(.system(size: 15, weight: .light))
                .lineLimit(1)

            Text("Код магазина: \(viewModel.profileViewModel.userProfile.storeCode)")
                .foregroundColor(.black)
                .font(.system(size: 15, weight: .light))
                .lineLimit(1)

            HStack {
                Text("Адрес: ")
                    .foregroundColor(.black)
                    .font(.system(size: 15, weight: .light))
                +
                Text(viewModel.profileViewModel.userProfile.storeAddress)
                    .foregroundColor(.black)
                    .font(.system(size: 15, weight: .light))
            }

            HStack {
                Text("Телефон: \(viewModel.profileViewModel.userProfile.storePhoneNumber)")
                    .foregroundColor(.black)
                    .font(.system(size: 15, weight: .light))
                    .lineLimit(1)
            }

            HStack {
                Text("\(selectedProductCount) товара")
                    .font(.title3)
                    .bold()
                    .foregroundColor(.black)

                Spacer()
                Text("\(Int(viewModel.cartViewModel.selectedTotalPrice)) ₽")
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
                .font(.system(size: 20, weight: .regular))

            TextField("Ваш комментарий", text: $comment)
                .padding()
                .background(Color.white)
                .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.colorGreen, lineWidth: 1))
        }
    }

    private var orderButton: some View {
        NavigationLink(destination: SuccessfullOrderView(viewModel: viewModel).navigationBarHidden(true), isActive: $showSuccessView) {
            Button(action: {
                Task {
                    var selectedProducts = viewModel.cartViewModel.cartProduct.filter {
                        viewModel.cartViewModel.selectedProducts[$0.id] == true
                    }

                    if selectedProducts.isEmpty {
                        selectedProducts = viewModel.cartViewModel.cartProduct
                    }

                    guard !selectedProducts.isEmpty else {
                        print("Нет продуктов для заказа.")
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
                        showSuccessView = true
                        

                    } catch {
                        print("Ошибка при создании заказа: \(error.localizedDescription)")
                    }
                }
            }) {
                Text("Заказать")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.colorGreen)
                    .cornerRadius(15)
                    .foregroundColor(.white)
            }
        }
      
        }
    private var selectedProductCount: Int {
        viewModel.cartViewModel.cartProduct.filter { viewModel.cartViewModel.selectedProducts[$0.id] == true }.count
    }
    }



struct CheckoutView_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutView(viewModel: MainViewModel(), products: [Product]())
    }
}
