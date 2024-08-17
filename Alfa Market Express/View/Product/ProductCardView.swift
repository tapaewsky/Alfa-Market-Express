//
//   ProductCardView.swift
//  WareHouse1
//
//  Created by Said Tapaev on 06.07.2024.
//

import SwiftUI

import SwiftUI

struct ProductCardView: View {
    var product: Product
    @ObservedObject var viewModel: ProductViewModel
    var onFavoriteToggle: () -> Void
    private let customGreen = Color(red: 38 / 255, green: 115 / 255, blue: 21 / 255)
    
    var body: some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: URL(string: product.imageUrl)) { image in
                    image.resizable()
                } placeholder: {
                    ProgressView()
                }
                .aspectRatio(contentMode: .fill)
                .cornerRadius(10)
                .clipped()
                .shadow(radius: 2)
                
                Button(action: {
                    onFavoriteToggle()
                }) {
                    Image(systemName: product.isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(product.isFavorite ? .yellow : .gray)
                        .padding(10)
                }
            }

            Text(String(format: "%.2f₽", product.price))
                .font(.headline)
                .foregroundColor(.black)
            
            Text(product.name)
                .font(.subheadline)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .foregroundColor(.primary)
            
            Spacer()
            
            if product.isInCart {
                HStack {
                    Button(action: {
                        if product.quantity > 1 {
                            viewModel.updateProduct(product)
                            viewModel.products[viewModel.products.firstIndex(where: { $0.id == product.id })!].quantity -= 1
                        } else {
                            viewModel.removeFromCart(product)
                        }
                    }) {
                        Image(systemName: "minus")
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(4)
                    }
                    
                    Text("\(product.quantity) кг")
                        .padding(.horizontal)
                        .font(.body)
                        .foregroundColor(.black)
                    
                    Button(action: {
                        viewModel.updateProduct(product)
                        viewModel.products[viewModel.products.firstIndex(where: { $0.id == product.id })!].quantity += 1
                    }) {
                        Image(systemName: "plus")
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(4)
                    }
                }
                .padding(.top, 10)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
            } else {
                Button(action: {
                    viewModel.addToCart(product)
                }) {
                    Text("В корзину")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(customGreen)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

//struct ProductCardView_Previews: PreviewProvider {
//    static var previews: some View {
//        let product = Product(
//            id: 1,
//            name: "Картофель белый",
//            description: "Свежий картофель",
//            price: 1,
//            imageUrl: "https://your-image-url.com/potato.jpg",
//            category: 1,
//            isFavorite: false
//        )
//        
//       
//        let viewModel = ProductViewModel()
//        
//        ProductCardView(
//            product: product,
//            viewModel: viewModel,
//            onFavoriteToggle: {
//                
//            }
//        )
//        .previewLayout(.sizeThatFits)
//        .padding()
//    }
//}
