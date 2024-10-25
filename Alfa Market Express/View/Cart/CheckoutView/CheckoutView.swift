//
//  olacingAnOrder.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 29.09.2024.
//

import SwiftUI

// MARK: - CheckoutView

struct CheckoutView: View {
    @ObservedObject var viewModel: MainViewModel
    @Binding var selectedTab: Int
    @State private var showSuccessView = false
    @State private var comment: String = ""
    @Environment(\.presentationMode) var presentationMode
    var products: [Product]
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            VStack {
                selectedProductsList
                orderDetails
                Spacer()
                commentSection
                Spacer()
                orderButton
                Spacer()
            }
            .padding()
            .navigationBarItems(leading: backButton)
        }
        .onAppear { setupView() }
        .navigationBarBackButtonHidden(true)
    }
    
    private var backButton: some View {
        CustomBackButton(label: "Назад", color: .colorGreen) {
            self.presentationMode.wrappedValue.dismiss()
        }
    }
    
    private var selectedProductsList: some View {
        ProductListView(viewModel: viewModel)
            .padding(.vertical, 2)
            .padding(.horizontal, 15)
    }
    
    private var orderDetails: some View {
        OrderDetailsView(viewModel: viewModel)
    }
    
    private var commentSection: some View {
        CommentSection(comment: $comment)
    }
    
    private var orderButton: some View {
        Button(action: placeOrder) {
            Text("Заказать")
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.colorGreen)
                .cornerRadius(15)
                .foregroundColor(.white)
        }
        .background(
            NavigationLink(destination: SuccessfullOrderView(viewModel: viewModel, selectedTab: $selectedTab).navigationBarHidden(true), isActive: $showSuccessView) {
                EmptyView()
            }
        )
    }
    
    private func setupView() {       
        viewModel.profileViewModel.fetchUserProfile { _ in }
    }
    
    private func placeOrder() {
        Task {
            var selectedProducts = viewModel.cartViewModel.cartProduct.filter {
                viewModel.cartViewModel.selectedProducts[$0.id] == true
            }
            if selectedProducts.isEmpty {
                selectedProducts = viewModel.cartViewModel.cartProduct
            }
            guard !selectedProducts.isEmpty else { return }

            do {
                let orderItems = try selectedProducts.map {
                    viewModel.ordersViewModel!.orderItemFromCartProduct($0)
                }
                let order = try await viewModel.ordersViewModel!.createOrder(
                    items: orderItems,
                    comments: comment,
                    accessToken: viewModel.ordersViewModel!.authManager.accessToken ?? ""
                )
                print("Заказ успешно создан: \(order)")
                showSuccessView = true
            } catch {
                print("Ошибка при создании заказа: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - ProductListView

struct ProductListView: View {
    @ObservedObject var viewModel: MainViewModel
    
    var body: some View {
        ScrollView {
            VStack {
                let selectedProducts = viewModel.cartViewModel.cartProduct.filter {
                    viewModel.cartViewModel.selectedProducts[$0.id] == true
                }
                let productsToShow = selectedProducts.isEmpty ? viewModel.cartViewModel.cartProduct : selectedProducts
                
                ForEach(productsToShow, id: \.id) { cartProduct in
                    CartItemCheckout(cartProduct: Binding<CartProduct>(
                        get: { cartProduct },
                        set: { _ in }
                    ))
                }
            }
        }
    }
}

// MARK: - OrderDetailsView

struct OrderDetailsView: View {
    @ObservedObject var viewModel: MainViewModel
    
    var body: some View {
        VStack {
            Text("Оформление заказа")
                .bold()
                .font(.title3)
            storeInfo
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
                    .font(.system(size: 15, weight: .light)) +
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
        .padding() // Убираем фиксированные отступы и используем общее значение
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 1)
    }
    
    private var selectedProductCount: Int {
        viewModel.cartViewModel.cartProduct.filter { viewModel.cartViewModel.selectedProducts[$0.id] == true }.count
    }
}

// MARK: - CommentSection

struct CommentSection: View {
    @Binding var comment: String
    
    var body: some View {
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
}

// MARK: - Preview

struct CheckoutView_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutView(viewModel: MainViewModel(), selectedTab: .constant(0), products: [Product]())
    }
}
