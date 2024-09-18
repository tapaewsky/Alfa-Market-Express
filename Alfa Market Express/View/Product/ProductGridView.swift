//
//  ProductGridView.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 28.07.2024.
//
import SwiftUI

struct ProductGridView: View {
    @ObservedObject var viewModel: ProductViewModel
    @ObservedObject var cartViewModel: CartViewModel
    @ObservedObject var favoritesViewModel: FavoritesViewModel
    var onFavoriteToggle: (Product) -> Void

    var body: some View {
        VStack {
            HStack {
                Text("Популярное")
                    .padding(.leading)
                    .bold()
                    .font(.title3)
                Spacer()
            }
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 5) {
                ForEach(viewModel.filteredProducts) { product in
                    NavigationLink(destination: ProductDetailView(viewModel: viewModel, cartViewModel: cartViewModel, favoritesViewModel: favoritesViewModel, product: product)) {
                        ProductCardView(product: product, viewModel: viewModel, onFavoriteToggle: {
                            onFavoriteToggle(product) 
                        })
                        .padding(5)
                    }
                }
            }
            
        }
    }
}
