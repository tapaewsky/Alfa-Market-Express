//
//  CheckoutVIew.swift
//  AlfaMarketExpress
//
//  Created by Said Tapaev on 24.12.2024.
//

import SwiftUI

struct CheckoutView: View {
    @StateObject var viewModel: MainViewModel
    @Binding var selectedTab: Int
    @Binding var totalPrice: Double
    @Binding var productCount: Int
    @State private var showSuccessView = false
    @State private var comment: String = ""
    @Environment(\.presentationMode) var presentationMode
    var products: [Product]
    
    @State private var isLoadingUserProfile: Bool = true

    init(viewModel: MainViewModel, selectedTab: Binding<Int>, totalPrice: Binding<Double>, productCount: Binding<Int>, products: [Product]) {
        _viewModel = StateObject(wrappedValue: viewModel)
        _selectedTab = selectedTab
        _totalPrice = totalPrice
        _productCount = productCount
        self.products = products
    }
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                selectedProductsList

                VStack {
                    orderDetails
                    commentSection
                    orderButton
                       
                }
                .padding()
            }
            .navigationBarItems(leading: backButton)
            .onAppear(perform: loadUserProfile)
        }
        .navigationBarBackButtonHidden(true)
    }

    private var backButton: some View {
        CustomBackButton {
            self.presentationMode.wrappedValue.dismiss()
        }
    }
    
    private var selectedProductsList: some View {
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
            .padding(.vertical, 2)
            .padding(.horizontal, 15)
        
        }
    }
    
    private var orderDetails: some View {
        VStack {
            Text("Оформление заказа")
                .bold()
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 12) {
                if isLoadingUserProfile {
                    ProgressView()
                        .frame(maxWidth: .infinity, minHeight: 145)
                } else {
                    
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
                        Text("\(productCount) товара")
                            .font(.title3)
                            .bold()
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        Text("\(Int(totalPrice)) ₽")
                            .foregroundColor(Color("colorRed"))
                            .font(.title3)
                            .bold()
                    }
                }
            }
            .padding()
            .background(.white)
            .cornerRadius(15)
            .shadow(radius: 1)
        }
        
    }
    
    private var commentSection: some View {
        VStack(alignment: .leading) {
            Text("Комментарий к заказу")
                .foregroundColor(.black)
                .font(.system(size: 20, weight: .regular))
            
            TextField("Ваш комментарий", text: $comment)
                .padding()
                .background(Color.white)
                .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color("colorGreen"), lineWidth: 1))
        }
    }
    
    private var orderButton: some View {
        Button(action: placeOrder) {
            Text("Заказать")
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color("colorGreen"))
                .cornerRadius(15)
                .foregroundColor(.white)
        }
        .background(
            NavigationLink(destination: SuccessfullOrderView(viewModel: viewModel, selectedTab: $selectedTab).navigationBarHidden(true), isActive: $showSuccessView) {
                EmptyView()
            }
        )
    }
    
    private func loadUserProfile() {
        isLoadingUserProfile = true
        viewModel.profileViewModel.fetchUserProfile { success in
            DispatchQueue.main.async {
                isLoadingUserProfile = false
                if !success {
                    print("Ошибка загрузки профиля")
                }
            }
        }
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

// MARK: - Preview

//struct CheckoutView_Previews: PreviewProvider {
//    static var previews: some View {
//        CheckoutView(viewModel: MainViewModel(), selectedTab: .constant(0), products: [Product]())
//    }
//}
