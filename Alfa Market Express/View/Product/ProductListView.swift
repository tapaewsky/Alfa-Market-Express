//
//  ProductListView.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 29.07.2024.
//

import SwiftUI

struct ProductListView: View {
    let category: Category
    @StateObject var viewModel = ProductViewModel()

    var body: some View {
        List(viewModel.filteredProducts) { product in
            ProductRowView(product: product)
        }
        .navigationTitle(category.name)
//        .onAppear {
//            viewModel.fetchProductsByCategory(category.id)
//        }
    }
}

struct ProductListView_Previews: PreviewProvider {
    static var previews: some View {
        ProductListView(category: Category(id: 1, name: "Sample Category", description: "", image: "https://via.placeholder.com/150"))
    }
}
