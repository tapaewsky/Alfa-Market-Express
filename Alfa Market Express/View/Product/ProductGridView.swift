//
//  ProductGridView.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 28.07.2024.
//
import SwiftUI

struct ProductGridView: View {
    @ObservedObject var viewModel: MainViewModel
    var products: [Product] 
    var onFavoriteToggle: (Product) -> Void
    
    var body: some View {
        
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 1), GridItem(.flexible(), spacing: 1)], spacing: 1) {
                ForEach(products) { product in
                    NavigationLink(destination: ProductDetailView(
                        viewModel: viewModel,
                        product: product)) {
                            
                            ProductCardView(
                                product: product,
                                viewModel: viewModel,
                                onFavoriteToggle: {
                                    onFavoriteToggle(product)
                                }
                            )
                            .padding(5)
                        }
                }
            
        }
        .padding(.horizontal, 10)
    }
}
