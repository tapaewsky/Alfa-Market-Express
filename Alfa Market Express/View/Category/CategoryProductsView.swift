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

    var body: some View {
        
            VStack {
                if let category = selectedCategory {
                    ScrollView {
                        if viewModel.productViewModel.products.isEmpty && !isFetching {
                            Text("Нет доступных продуктов для категории: \(category.name)")
                                .padding()
                        } else {
                            ProductGridView(
                                viewModel: viewModel,
                                products: viewModel.productViewModel.products.filter { $0.category == category.id },
                                onFavoriteToggle: { _ in }
                            )
                            
                        }
                    }
                    .onAppear {
                        loadProducts(for: category)
                    }
                } else { 
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 1)], spacing: 10) {
                        ForEach(viewModel.categoryViewModel.categories) { category in
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

    private func loadProducts(for category: Category) {
        isFetching = true
        viewModel.productViewModel.fetchProducts { success in
            DispatchQueue.main.async {
                isFetching = false
                if success {
                    print("Продукты успешно загружены для категории \(category.name)")
                } else {
                    print("Не удалось загрузить продукты для категории \(category.name)")
                }
            }
        }
    }
}
