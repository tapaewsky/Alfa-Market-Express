//
//  CategoryProductsView.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 29.07.2024.
//
import SwiftUI

struct CategoryProductsView: View {
    @StateObject var viewModel: MainViewModel
    let category: Category

    var body: some View {
        List(viewModel.productViewModel.products.filter { $0.category == category.id }) { product in
            NavigationLink(destination: ProductDetailView(viewModel: viewModel, product: product)) {
                ProductRowView(product: product, viewModel: viewModel.productViewModel) {}
            }
        }
        .navigationTitle(category.name)
    }
}
