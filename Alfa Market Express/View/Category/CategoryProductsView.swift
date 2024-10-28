//
//  CategoryProductsView.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 29.07.2024.
//
import SwiftUI

struct CategoryProductsView: View {
    @StateObject var viewModel: MainViewModel
    @State private var selectedCategory: Category? = nil
    @State private var isFetching: Bool = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            if let category = selectedCategory {

                HStack {
                    Button(action: {
                        selectedCategory = nil
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.colorGreen)
                            Text("Назад")
                                .foregroundColor(.black)
                        }
                    }
                    .padding()

                    Spacer()
                }

                ScrollView {
                    let filteredProducts = category.id == 0
                        ? viewModel.productViewModel.products
                        : viewModel.productViewModel.products.filter { $0.category == category.id }
                    
                    if filteredProducts.isEmpty && !isFetching {
                        Text("Нет доступных продуктов для категории: \(category.name)")
                            .padding()
                    } else {
                        ProductGridView(
                            viewModel: viewModel,
                            products: filteredProducts,
                            onFavoriteToggle: { _ in }
                        )
                    }
                }

            } else {
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 1)], spacing: 10) {
                    ForEach(viewModel.categoryViewModel.categories, id: \.id) { category in
                        Button(action: {
                            selectedCategory = category
                        }) {
                            CategoryCardView(category: category)
                        }
                    }
                }
                .padding()
            }
        }
    }
}

