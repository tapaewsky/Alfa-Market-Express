//
//  ProductGridView.swift
//  AlfaMarketExpress
//
//  Created by Said Tapaev on 24.12.2024.
//

import SwiftUI

struct ProductGridView: View {
    @ObservedObject var viewModel: MainViewModel
    var products: [Product]
    var onFavoriteToggle: (Product) -> Void

    var body: some View {
        // Просто отобразим карточки без использования LazyVGrid здесь
        VStack {
            ForEach(products) { product in
                NavigationLink(destination: ProductDetailView(viewModel: viewModel,
                                                              product: product))
                {
                    ProductCardView(product: product,
                                    viewModel: viewModel,
                                    onFavoriteToggle: {
                                        onFavoriteToggle(product)
                                    })
                                    .padding(5)
                }
            }
        }
    }
}
