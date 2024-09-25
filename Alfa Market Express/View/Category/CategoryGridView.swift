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
        let columns = [
            GridItem(.adaptive(minimum: 150), spacing: 15)
        ]
        
        LazyVGrid(columns: columns, spacing: 15) {
            ForEach(viewModel.categoryViewModel.categories) { category in
                NavigationLink(destination: CategoryProductsView(viewModel: viewModel, category: category)) {
                    CategoryCardView(category: category)
                }
            }
        }
        .padding(.horizontal, 10)
    }
}
