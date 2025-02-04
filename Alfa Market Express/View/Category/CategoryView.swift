//
//  CatalogView.swift
//  WareHouse1
//
//  Created by Said Tapaev on 06.07.2024.
//

import SwiftUI
import Kingfisher

struct CategoryView: View {
    @StateObject var viewModel: MainViewModel
    @StateObject var networkMonitor: NetworkMonitor = NetworkMonitor()
    @State var isFetching: Bool = false
    @State var selectedCategory: Category? = nil

    var body: some View {
        VStack {
            HeaderView {
                SearchBar(viewModel: viewModel)
            }

            if networkMonitor.isConnected {
                ScrollView {
                    if viewModel.categoryViewModel.categories.isEmpty && !isFetching {
                        Text("Нет доступных категорий")
                            .padding()
                    } else {
                        if let selectedCategory = selectedCategory {
                            CategoryProductsView(viewModel: viewModel, selectedCategory: $selectedCategory)
                        } else {
                            categoryGridView
                        }
                    }
                }
                .onAppear {
                    loadCategories()
                }
            } else {
                NoInternetView(viewModel: viewModel)
                    .padding()
            }
        }
    }

    private func loadCategories() {
        isFetching = true

        viewModel.categoryViewModel.fetchCategory { success in
            DispatchQueue.main.async {
                isFetching = false
                if success {
                    // Categories loaded successfully
                } else {
                    print("Не удалось загрузить категории")
                }
            }
        }
    }

    private var categoryGridView: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
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

struct CategoryView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryView(viewModel: MainViewModel())
    }
}
