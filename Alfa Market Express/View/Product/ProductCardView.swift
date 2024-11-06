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
            productImageAndFavoriteButton
                .padding(0)
            Spacer()
            productDetails
            productPriceAndCartButton
            cartButton
                .padding(.horizontal)
               
        }
        .background(.clear)
        .onAppear {
            isFavorite = viewModel.favoritesViewModel.isFavorite(product)
            
        }
    }
    
    private var productImageAndFavoriteButton: some View {
        ZStack(alignment: .topTrailing) {
            Group {
                if let imageUrl = product.imageUrl, let url = URL(string: imageUrl) {
                    KFImage(url)
                        .placeholder {
                            ProgressView()
                        }
                        .resizable()
                        .cornerRadius(20)
                        .scaledToFit()
                        .overlay(discountPercentageView, alignment: .bottomLeading)
                } else {
                    Image("plaseholderProduct")
                        .resizable()
                        .cornerRadius(20)
                        .scaledToFit()
                        .overlay(discountPercentageView, alignment: .bottomLeading)
                }
            }

            Button(action: {
                Task {
                    await someFunctionThatCallsToggleFavorite()
                    isFavorite.toggle()
                }
            }) {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .foregroundColor(isFavorite ? .colorGreen : .gray)
            }
            .padding()
        }
    }

    private var discountPercentageView: some View {
        VStack {
            if let originalPrice = Double(product.price),
               let discountedPrice = product.discountedPrice,
               discountedPrice < originalPrice {
                let discountPercentage = (1 - discountedPrice / originalPrice) * 100
                Text(String(format: "-%.0f%%", discountPercentage))
                    .font(.caption)
                    .foregroundColor(.black)
                    .padding(5)
                    .background(.white.opacity(0.8))
                    .cornerRadius(3)
            }
        }
        .padding(0)
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
              if let originalPrice = Double(product.price) {
                  if let discountedPrice = product.discountedPrice, discountedPrice < originalPrice {
                      HStack {
                          Text(String(format: "%.0f₽", discountedPrice))
                              .font(.headline)
                              .foregroundColor(.colorRed)
                          
                          Text(String(format: "%.0f₽", originalPrice))
                              .font(.subheadline)
                              .foregroundColor(.gray)
                              .strikethrough()
                      }
                  } else {
                      Text(String(format: "%.0f₽", originalPrice))
                          .font(.headline)
                          .foregroundColor(.colorRed)
                  }
              } else {
                  Text("Цена недоступна")
                      .font(.headline)
                      .foregroundColor(.gray)
              }
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
            print("Product to remove: \(product.id), name: \(product.name)")

            await viewModel.cartViewModel.removeFromCard(product)
        } else {
            await viewModel.cartViewModel.addToCart(product, quantity: quantity)
        }
        isAddedToCart.toggle()
    }

    private func someFunctionThatCallsToggleFavorite() async {
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
//            imageUrl: "https://avatars.mds.yandex.net/i?id=8e94bb0804af03474956f3d282b1f3b62a783e17-10639895-images-thumbs&n=13",
//            category: 2,
//            isFavorite: false,

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
