//
//  CartItemView.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 12.09.2024.
//
import SwiftUI
import Kingfisher

struct CartItemView: View {
    @ObservedObject var viewModel: MainViewModel
    var product: Product
    @State private var quantity: Int
    @State private var totalPriceForProduct: Double
    var cartProduct: CartProduct
    @State var isSelected: Bool = false
    
    @Environment(\.isSelectionMode) var isSelectionMode
    
    init(cartProduct: CartProduct, viewModel: MainViewModel, product: Product, isSelected: Binding<Bool>) {
        self.cartProduct = cartProduct
        self._quantity = State(initialValue: cartProduct.quantity)
        self._totalPriceForProduct = State(initialValue: cartProduct.getTotalPrice)
        self.viewModel = viewModel
        self.product = product
//        self._isSelected = isSelected
    }
    
    var body: some View {
        ZStack {
            background
            HStack {
                productImage
                NavigationLink(destination: ProductDetailView(viewModel: viewModel, product: product)) {
                    productDetails
                }
                Spacer()
                deleteButton
            }
        }
        .onChange(of: quantity) { _ in updateQuantity() }
        .onAppear { updateSelection() }
        .onChange(of: viewModel.cartViewModel.selectedProducts[cartProduct.id]) { newValue in
            isSelected = newValue ?? false
        }
    }
    
    // Background для карточки
    private var background: some View {
        RoundedRectangle(cornerRadius: 15)
            .fill(Color.white)
            .shadow(radius: 2)
    }
    
    // Изображение продукта
    private var productImage: some View {
        ZStack(alignment: .topLeading) {
            if let imageUrl = URL(string: cartProduct.product.imageUrl ?? "") {
                KFImage(imageUrl)
                    .placeholder { ProgressView()}
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: 115, maxHeight: 150)
                    .cornerRadius(15)
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: 115, maxHeight: 150)
            }
            
            if isSelectionMode {
                selectButton
            }
        }
    }
    
    // Детали продукта
    private var productDetails: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(cartProduct.product.name)
                .font(.headline)
                .lineLimit(1)
                .foregroundColor(.black)
            
            Text("\(Int(totalPriceForProduct)) ₽")
                .font(.subheadline)
                .foregroundColor(.colorRed)
            
            Text(cartProduct.product.description)
                .font(.footnote)
                .lineLimit(2)
                .foregroundColor(.black)
            
            quantityControl
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // Контроллер количества
    private var quantityControl: some View {
        HStack {
            controlButton(systemName: "minus", action: decreaseQuantity)
            Text("\(quantity)").padding(.horizontal, 5).foregroundColor(.black)
            controlButton(systemName: "plus", action: increaseQuantity)
        }
        .padding(7)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(15)
    }
    
    // Кнопка удаления
    private var deleteButton: some View {
        Button(action: { Task { await toggleCart() } }) {
            Image(systemName: "trash")
                .foregroundColor(.colorGreen)
                .padding()
        }
    }
    
    // Кнопка выбора
    private var selectButton: some View {
        Button(action: {
            Task {
                await toggleSelection() // Асинхронная функция для обновления логики выбора
                isSelected.toggle() // Переключение состояния вручную
            }
        }) {
            Image(systemName: isSelected ? "checkmark.square" : "square")
                .foregroundColor(isSelected ? .colorGreen : .gray)
                .padding(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // Универсальная кнопка контроллера
    private func controlButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName).foregroundColor(.black)
        }
        .buttonStyle(PlainButtonStyle())
        .contentShape(Circle())
    }
    
    // Увеличение количества
    private func increaseQuantity() {
        quantity += 1
        updateQuantity()
    }
    
    // Уменьшение количества
    private func decreaseQuantity() {
        if quantity > 1 {
            quantity -= 1
            updateQuantity()
        }
    }
    
    // Методы управления логикой
    private func calculateTotalPrice() {
        totalPriceForProduct = (Double(cartProduct.product.price) ?? 0) * Double(quantity)
    }
    
    private func updateQuantity() {
        Task {
            await viewModel.cartViewModel.updateProductQuantity(cartProduct.product, newQuantity: quantity)
            calculateTotalPrice()
        }
    }
    
    private func toggleSelection() async {
        isSelected.toggle()
        viewModel.cartViewModel.selectedProducts[cartProduct.id] = isSelected
        if isSelected {
            viewModel.cartViewModel.selectProduct(cartProduct)
        } else {
            viewModel.cartViewModel.deselectProduct(cartProduct)
        }
        viewModel.cartViewModel.updateSelectedTotalPrice()
    }
    
    private func updateSelection() {
        isSelected = viewModel.cartViewModel.selectedProducts[cartProduct.id] ?? false
    }
    
    private func toggleCart() async {
        await viewModel.cartViewModel.removeFromCart(product)
    }
}

//struct CartItemViewPreview_Previews: PreviewProvider {
//    static var previews: some View {
//        let mainViewModel = MainViewModel()
//        
//        let previewProduct = Product(
//            id: 1,
//            name: "Gorilla Mango",
//            description: "A delicious tropical fruit drink.",
//            price: "150",
//            imageUrl: "https://avatars.mds.yandex.net/i?id=04b02b669571a1111bd5ed7cb534b33956285d63-12714990-images-thumbs&n=13",
//            category: 2,
//            isFavorite: false,
//            isInCart: true,
//            quantity: 1
//        )
//        
//        let previewCartProduct = CartProduct(
//            id: 1,
//            product: previewProduct,
//            quantity: 1, getTotalPrice: 12
//        )
//        
//        return CartItemView(
//            cartProduct: previewCartProduct,
//            viewModel: mainViewModel,
//            product: previewProduct,
//            isSelected: .constant(false) // Пример привязки
//        )
//        .previewLayout(.sizeThatFits)
//        .padding()
//    }
//}
