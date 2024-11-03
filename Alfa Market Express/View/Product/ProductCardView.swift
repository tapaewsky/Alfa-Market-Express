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
                if let imageUrl = product.imageUrl, let url = URL(string: imageUrl) {
                    KFImage(url)
                        .placeholder {
                            Image("plaseholder")
                                .resizable()
                                .cornerRadius(20)
                                .scaledToFit()
                        }
                        .resizable() 
                        .cornerRadius(20)
                        .scaledToFit()
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
