//
//  CategoryProductsView.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 29.07.2024.
//

import SwiftUI

struct CategoryProductsView: View {
    @ObservedObject var viewModel: ProductViewModel
    @ObservedObject var cartViewModel: CartViewModel
    @ObservedObject var favoritesViewModel: FavoritesViewModel
    let category: Category
    
    var body: some View {
        List(viewModel.products.filter { $0.category == category.id }) { product in
            NavigationLink(destination: ProductDetailView(viewModel: viewModel, cartViewModel: cartViewModel, favoritesViewModel: favoritesViewModel, product: product)) {
                ProductRowView(product: product, viewModel: viewModel) {
                }
            }
        }
        .navigationTitle(category.name)
    }
}
