//
//  CategoriesGridView.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 29.07.2024.
//

import SwiftUI

struct CategoryGridView: View {
    @ObservedObject var viewModel: CategoryViewModel
    let productViewModel = ProductViewModel()
    let cartViewModel = CartViewModel()
    let favoritesViewModel = FavoritesViewModel()
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 40), GridItem(.flexible(), spacing: 10)], spacing: 5) {
            ForEach(viewModel.categories) { category in
                NavigationLink(destination: CategoryProductsView(viewModel: productViewModel, cartViewModel: cartViewModel, favoritesViewModel: favoritesViewModel, category: category)) {
                    CategoryCardView(category: category)
                        .padding(5)
                }
            }
            
        }
       
    }
}
