//
//  ProductGridView.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 28.07.2024.
//
import SwiftUI



struct ProductGridView: View {
    @ObservedObject var viewModel: ProductViewModel
    var onFavoriteToggle: () -> Void

    

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
            ForEach(viewModel.products) { product in
                NavigationLink(destination: ProductDetailView(viewModel: viewModel, product: product)) {
                    ProductCardView(product: product, viewModel: viewModel, onFavoriteToggle: {})
                        
                        .padding(5)
                        
                }
            }
        }

       
    }
}
