//
//  CartMainView.swift
//  AlfaMarketExpress
//
//  Created by Said Tapaev on 24.12.2024.
//


import SwiftUI
import Kingfisher

struct CartMainView: View {
    @StateObject var viewModel: MainViewModel
    @State private var isFetching = false
    @State private var isSelectionMode: Bool = false
    @State private var selectedTab: Int = 0
    @State private var totalPrice: Double = 0
    @State private var productCount: Int = 0
    @State private var cardOffset: CGFloat = 0
    @State var authManager: AuthManager = .shared
    @State var showCheckoutView = false

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
        .onChange(of: viewModel.cartViewModel.selectedTotalPrice) { newValue in
            totalPrice = newValue
            productCount = selectedOrAllProducts().count
            onCartUpdated()
        }
    }
    
    private func loadCart() {
        isFetching = true
        viewModel.cartViewModel.fetchCart { success in
            DispatchQueue.main.async {
                isFetching = false
                if success {
                    updateTotalPrice()
                    productCount = selectedOrAllProducts().count
                } else {
                    print("Не удалось загрузить корзину")
                }
            }
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
                .foregroundColor(Color("colorGreen"))
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
                updateTotalPrice()
                productCount = selectedOrAllProducts().count
            }
        )
        
        return ZStack {
            HStack {
                if isSelectionMode {
                    Button(action: {
                        isSelected.wrappedValue.toggle()
                    }) {
                        Image(systemName: isSelected.wrappedValue ? "checkmark.square.fill" : "square")
                            .resizable()
                            .frame(width: 15, height: 15)
                            .foregroundColor(isSelected.wrappedValue ? Color("colorGreen") : .gray)
                    }
                    .padding(.trailing, 10)
                    .transition(.opacity)
                }
                
                CartItemView(
                    cartProduct: cartProduct,
                    viewModel: viewModel,
                    isSelected: isSelected,
                    onCartUpdated: onCartUpdated,
                    onTotalPriceUpdated: updateTotalPrice,
                    isSelectionMode: isSelectionMode
                )
                .offset(x: isSelectionMode ? 5 : 0)
                .animation(.easeInOut, value: isSelectionMode)
            }
            .padding(.vertical, 2)
            .padding(.horizontal, 15)
        }
    }
    
    private var footer: some View {
        HStack {
            Text("\(Int(totalPrice)) ₽")
                .font(.callout)
                .bold()
            
            Spacer()

            Button(action: {
                if authManager.accessToken != nil {
                    // Если токен существует, переходим в CheckoutView
                    showCheckoutView = true
                } else {
                    // Если токен отсутствует, отправляем уведомление
                    NotificationCenter.default.post(name: Notification.Name("SwitchToProfile"), object: nil)
                }
            }) {
                Text("Оформить заказ")
                    .font(.callout)
                    .padding(10)
                    .background(Color("colorGreen"))
                    .foregroundColor(.white)
                    .cornerRadius(15)
            }
            .background(
                NavigationLink(
                    destination: CheckoutView(
                        viewModel: viewModel,
                        selectedTab: $selectedTab,
                        totalPrice: $totalPrice,
                        productCount: $productCount,
                        products: selectedOrAllProducts()
                    ),
                    isActive: $showCheckoutView
                ) {
                    EmptyView()
                }
            )
            .disabled(viewModel.cartViewModel.cartProduct.isEmpty)
            .opacity(viewModel.cartViewModel.cartProduct.isEmpty ? 0.8 : 1)
        }
        .padding()
        .background(.white)
        .cornerRadius(10)
        .onChange(of: viewModel.cartViewModel.selectedTotalPrice) { newValue in
            totalPrice = newValue
            productCount = selectedOrAllProducts().count
        }
    }
            
    private func selectedOrAllProducts() -> [Product] {
        let selectedProducts = viewModel.cartViewModel.cartProduct.filter {
            viewModel.cartViewModel.selectedProducts[$0.id] == true
        }
        return selectedProducts.isEmpty ? viewModel.cartViewModel.cartProduct.map { $0.product } : selectedProducts.map { $0.product }
    }

    private func toggleSelectionMode() {
        isSelectionMode.toggle()
        if isSelectionMode {
            let selectedCount = viewModel.cartViewModel.selectedProducts.filter { $0.value }.count
            if selectedCount == 0 {
                totalPrice = 0
            }
        } else {
            viewModel.cartViewModel.clearSelection()
            viewModel.cartViewModel.updateSelectedTotalPrice()
            viewModel.cartViewModel.selectedProducts = [:]
            totalPrice = calculateTotalPrice()
            productCount = viewModel.cartViewModel.cartProduct.count
        }
    }
    func calculateTotalPrice() -> Double {
        return viewModel.cartViewModel.cartProduct.reduce(0) { $0 + $1.getTotalPrice }
        
    }
    
    func updateTotalPrice() {
        if isSelectionMode {
            totalPrice = viewModel.cartViewModel.selectedProducts.reduce(0) { result, pair in
                let (id, isSelected) = pair
                if isSelected, let cartProduct = viewModel.cartViewModel.cartProduct.first(where: { $0.id == id }) {
                    return result + cartProduct.getTotalPrice
                }
                return result
            }
        } else {
            totalPrice = calculateTotalPrice()
        }
    }
    private func onCartUpdated() {
        loadCart()
    }
}

struct CartMainView_Previews: PreviewProvider {
    static var previews: some View {
        CartMainView(viewModel: MainViewModel())
    }
}
