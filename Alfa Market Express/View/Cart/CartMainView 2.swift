import SwiftUI
import Kingfisher

struct CartMainView: View {
    @StateObject var viewModel: MainViewModel
    @State private var isFetching = false
    @State private var isSelectionMode: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            header
            
            ZStack {
                if viewModel.cartViewModel.cartProduct.isEmpty && !isFetching {
                    emptyCartView
                } else {
                    cartContent
                }
            }
            .frame(maxHeight: .infinity)
            
            footer
        }
        .padding(0)
        .onAppear(perform: loadCart)
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }

    private var header: some View {
        HStack {
            Text(isSelectionMode ? "Выбрано: \(viewModel.cartViewModel.selectedProducts.filter { $0.value }.count)" : "Корзина \(Set(viewModel.cartViewModel.cartProduct.map { $0.product.id }).count) товаров")
                .font(.headline)
                .foregroundColor(.gray)
            Spacer()
            Button(action: toggleSelectionMode) {
                Text(isSelectionMode ? "Отменить" : "Выбрать")
                    .font(.headline)
                    .foregroundColor(.colorGreen)
            }
        }
        .padding()
    }

    private var emptyCartView: some View {
        Text("Корзина пуста")
            .padding()
            .foregroundColor(.gray)
    }
    
    private var cartContent: some View {
        ScrollView(.vertical, showsIndicators: false) {
            ForEach(viewModel.cartViewModel.cartProduct, id: \.id) { cartProduct in
                CartItemView(
                    cartProduct: cartProduct,
                    viewModel: viewModel
                )
                .padding(.vertical, 2)
                .padding(.horizontal, 15)
                .environment(\.isSelectionMode, isSelectionMode)
            }
        }
        .frame(maxHeight: .infinity)
    }
    
    private var footer: some View {
        HStack {
            Text("\(Int(viewModel.cartViewModel.totalPrice)) ₽")
                .font(.callout)
                .bold()
            
            Spacer()
            
            NavigationLink(
                destination: CheckoutView(viewModel: viewModel, products: selectedOrAllProducts())
            ) {
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
    
    private func selectedOrAllProducts() -> [Product] {
        let selectedProducts = viewModel.cartViewModel.cartProduct.filter { viewModel.cartViewModel.selectedProducts[$0.id] == true }
        return selectedProducts.isEmpty ? viewModel.cartViewModel.cartProduct.map { $0.product } : selectedProducts.map { $0.product }
    }
    
    private func toggleSelectionMode() {
        isSelectionMode.toggle()
        viewModel.cartViewModel.clearSelection()
        viewModel.cartViewModel.selectAllProducts(false)
    }
}