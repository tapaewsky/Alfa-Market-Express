//
//   ProductCardView.swift
//  WareHouse1
//
//  Created by Said Tapaev on 06.07.2024.
//
import SwiftUI
import Kingfisher

struct ProductCardView: View {
    let product: Product
    @ObservedObject var viewModel: MainViewModel
    var onFavoriteToggle: () -> Void
    @State private var quantity: Int = 1
    @State private var isFavorite: Bool = false
    @State private var isAddedToCart: Bool = false

    var body: some View {
        
        VStack(alignment: .leading) {
//            RoundedRectangle(cornerRadius: 15)
//                .fill(Color.white)
//                .shadow(radius: 2)
            productImageAndFavoriteButton
                .padding(0)
            Spacer()
            productDetails
//                .padding()
//                .padding(.leading)
            productPriceAndCartButton
//                .padding()
//                .padding(.leading)
            cartButton
                .padding(.horizontal)
               
        }
        
        
//        .overlay(
//            RoundedRectangle(cornerRadius: 1)
//                .foregroundColor(.white)
//        )
        .background(.clear)
        
//        .shadow(radius: 2)
        .onAppear {
            isFavorite = viewModel.favoritesViewModel.isFavorite(product)
            isAddedToCart = viewModel.cartViewModel.isInCart(product)
        }
    }
    
    private var productImageAndFavoriteButton: some View {
        ZStack(alignment: .topTrailing) {
                if let imageUrl = product.imageUrl, let url = URL(string: imageUrl) {
                    KFImage(url)
//                        .placeholder {
//                            ProgressView()
//                        }
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 150, height: 150)
//                        .clipped()
////                        .background(.gray)
//                        .cornerRadius(10)
//                } else {
//                    Image(systemName: "photo")
//                        .resizable()
//                        .scaledToFit()
//                        .clipped()
//                }
                        .placeholder {
                            Image(systemName: "photo")
                                .resizable()
                                .background(.red)
                                .cornerRadius(20)
                                .scaledToFit()
                                .foregroundColor(.gray)
                        }
                        .resizable() 
                        .cornerRadius(20)
                        .scaledToFit()
//                        .frame(width: 150, height: 150)
                }
                
            Button(action: {
                someFunctionThatCallsToggleFavorite(product)
            }) {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .foregroundColor(isFavorite ? .red : .gray)
            }
            .padding()
        }
       
    }
  
    private var productDetails: some View {
        VStack(alignment: .leading) {
            Text(product.name)
                .font(.subheadline)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .foregroundColor(.primary)

            

            Text("Цена за 1 шт")
                .foregroundStyle(.gray)
        }
    }

    private var productPriceAndCartButton: some View {
        VStack {
            Text(String(format: "%.0f₽", Double(product.price) ?? 0))
                .font(.headline)
                .foregroundColor(.colorRed)
        }
    }

    private var cartButton: some View {
        VStack {
            HStack {
                Button(action: {
                    Task {
                        await toggleCart()
                    }
                }) {
                    Text(isAddedToCart ? "В корзине" : "В корзину")        
                    Image(systemName: isAddedToCart ? "cart.fill" : "cart")
                }
            }
            .padding(.vertical, 15)
            .frame(maxWidth: .infinity)
            .foregroundColor(.white)
            .background(isAddedToCart ? Color.gray : .colorGreen)
            .cornerRadius(15)
        }
    }

    private func toggleCart() async {
        if isAddedToCart {
            await viewModel.cartViewModel.removeFromCart(product)
        } else {
            await viewModel.cartViewModel.addToCart(product, quantity: quantity)
        }
        isAddedToCart.toggle()
    }

    private func someFunctionThatCallsToggleFavorite(_ product: Product) {
        Task {
            await viewModel.favoritesViewModel.toggleFavorite(for: product)
        }
    }
}

//struct ProductCardViewPreview_Previews: PreviewProvider {
//    static var previews: some View {
//        let mainViewModel = MainViewModel()
//        
//       
//        let previewProduct = Product(
//            id: 1,
//            name: "Gorilla Mango",
//            description: "A delicious tropical fruit drink.",
//            price: "150", 
//            imageUrl: "https://ir.ozone.ru/s3/multimedia-l/wc1000/6897748341.jpg",
//            category: 2,
//            isFavorite: false,
//            isInCart: true,
//            quantity: 1
//        )
//        
//        return ProductCardView(
//            product: previewProduct,
//            viewModel: mainViewModel,
//            onFavoriteToggle: {}
//        )
//        .previewLayout(.sizeThatFits)
//        .padding()
//    }
//}
