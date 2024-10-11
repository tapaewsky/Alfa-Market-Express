//
//  CategoriesGridView.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 29.07.2024.
//
import SwiftUI

struct CategoryGridView: View {
    @ObservedObject var viewModel: MainViewModel
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 1)], spacing: 10) {
            ForEach(viewModel.categoryViewModel.categories) { category in
                NavigationLink(destination: CategoryProductsView(viewModel: viewModel, category: category)) {
                    CategoryCardView(category: category)
                }
            }
        }
    }
}
