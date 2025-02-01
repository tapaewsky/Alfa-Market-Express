//
//  CategoryProductsView.swift
//  AlfaMarketExpress
//
//  Created by Said Tapaev on 24.12.2024.
//
import SwiftUI

struct CategoryProductsView: View {
    @StateObject var viewModel: MainViewModel
    @Binding var selectedCategory: Category?
    @State private var isFetching: Bool = false
    @State private var hasMoreData: Bool = true
    @State private var currentPage: Int = 1
    @Environment(\.presentationMode) var presentationMode
    @State private var scrollPosition: Int = 0

    var body: some View {
        VStack {
            HStack {
                CustomBackButton(action: {
                    selectedCategory = nil
                })
                .padding()
                
                Spacer()
            }
            
            if let selectedCategory = selectedCategory {
                ScrollViewReader { proxy in
                    productList(for: selectedCategory)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now()) {
                                proxy.scrollTo(0, anchor: .top)
                            }
                        }
                }
            }
        }
    }

    private func productList(for category: Category) -> some View {
        LazyVStack {
            let filteredProducts = filteredProducts(for: category)
            
            if filteredProducts.isEmpty && !isFetching {
                Text("Нет доступных продуктов для категории: \(category.name)")
                    .padding()
                    .id(0)
            } else {
                ProductGridView(
                    viewModel: viewModel,
                    products: filteredProducts,
                    onFavoriteToggle: { _ in }
                )
                .id(0)
            }
            
            if isFetching {
                ProgressView("Загрузка...")
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            
            if hasMoreData {
                GeometryReader { proxy in
                    Color.clear
                        .frame(height: 1)
                        .onAppear {
                            if proxy.frame(in: .global).maxY <= UIScreen.main.bounds.height {
                                loadMoreProducts()
                            }
                        }
                }
                .frame(height: 1)
            }
        }
    }

    private func loadMoreProducts() {
        guard !isFetching, hasMoreData else { return }

        isFetching = true
        viewModel.productViewModel.fetchProducts { success in
            DispatchQueue.main.async {
                if success {
                    if viewModel.productViewModel.baseURL == nil {
                        hasMoreData = false
                    }
                } else {
                    print("Не удалось загрузить следующую страницу")
                    hasMoreData = false
                }
                isFetching = false
            }
        }
    }

    private func loadInitialProducts(isRefreshing: Bool = false) {
        guard !isFetching else { return }
        isFetching = true
        let group = DispatchGroup()
        group.enter()
        viewModel.productViewModel.fetchProducts { success in
            DispatchQueue.main.async {
                if !success {
                    print("Не удалось загрузить продукты")
                }
                group.leave()
            }
        }
        group.notify(queue: .main) {
            isFetching = false
        }
    }

    private func filteredProducts(for category: Category) -> [Product] {
        return category.id == 0
        ? viewModel.productViewModel.products
        : viewModel.productViewModel.products.filter { $0.category == category.id }
    }
}
