//
//  CategoryProductsView.swift
//  AlfaMarketExpress
//
//  Created by Said Tapaev on 24.12.2024.
//

//import SwiftUI
//
//struct CategoryProductsView: View {
//    @StateObject var viewModel: MainViewModel
//    @Binding var selectedCategory: Category?
//    @State private var isFetching: Bool = false
//    @State private var hasMoreData: Bool = true
//    @State private var currentPage: Int = 1
//    @Environment(\.presentationMode) var presentationMode
//    @State private var scrollPosition: Int = 0
//    @State private var initialLoadDone: Bool = false
//
//    var body: some View {
//        VStack {
//            HStack {
//                CustomBackButton(action: {
//                    selectedCategory = nil
//                })
//                .padding()
//
//                Spacer()
//            }
//
//            if let selectedCategory {
//                ScrollViewReader { _ in
//                    productList(for: selectedCategory)
//                }
//            }
//        }
//    }
//
//    private func productList(for category: Category) -> some View {
//        VStack {
//            let filteredProducts = filteredProducts(for: category)
//
//            if filteredProducts.isEmpty, !isFetching {
//                Text("В этой категории пока нет товаров.")
//                    .padding()
//                    .foregroundColor(.gray)
//                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
//            } else {
//                LazyVGrid(columns: [GridItem(.flexible(), spacing: 1), GridItem(.flexible(), spacing: 1)], spacing: 1) {
//                    ForEach(filteredProducts, id: \.id) { product in
//                        ProductGridView(viewModel: viewModel,
//                                        products: [product],
//                                        onFavoriteToggle: { _ in })
//                            .id(product.id)
//                            .onAppear {
//                                if product == filteredProducts.last, hasMoreData {
//                                    loadMoreProducts()
//                                }
//                            }
//                    }
//                }
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//            }
//
//            if isFetching {
//                ProgressView("Загрузка...")
//                    .padding()
//                    .frame(maxWidth: .infinity, alignment: .center)
//            }
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//    }
//
//    private func loadMoreProducts() {
//        guard !isFetching, hasMoreData else { return }
//
//        isFetching = true
//        viewModel.productViewModel.fetchProducts { success in
//            DispatchQueue.main.async {
//                if success {
//                    if viewModel.productViewModel.baseURL == nil {
//                        hasMoreData = false
//                    }
//                } else {
//                    print("Не удалось загрузить следующую страницу")
//                    hasMoreData = false
//                }
//                isFetching = false
//            }
//        }
//    }
//
//    private func loadInitialProducts(isRefreshing _: Bool = false) {
//        guard !isFetching else { return }
//        isFetching = true
//        let group = DispatchGroup()
//        group.enter()
//        viewModel.productViewModel.fetchProducts { success in
//            DispatchQueue.main.async {
//                if !success {
//                    print("Не удалось загрузить продукты")
//                }
//                group.leave()
//            }
//        }
//        group.notify(queue: .main) {
//            isFetching = false
//        }
//    }
//
//    private func filteredProducts(for category: Category) -> [Product] {
//        category.id == 0
//            ? viewModel.productViewModel.products
//            : viewModel.productViewModel.products.filter { $0.category == category.id }
//    }
//}
import SwiftUI

struct CategoryProductsView: View {
    @StateObject var viewModel: MainViewModel
    @Binding var selectedCategory: Category?
    @State private var isFetching: Bool = false
    @State private var hasMoreData: Bool = true
    @Environment(\.presentationMode) var presentationMode
    @State private var initialLoadDone: Bool = false

    var body: some View {
        VStack {
            HStack {
                CustomBackButton(action: {
                    selectedCategory = nil
                })
                .padding()

                Spacer()
            }

            if let selectedCategory {
                ScrollViewReader { _ in
                    productList()
                        .onAppear {
                            if !initialLoadDone {
                                initialLoadDone = true
                                loadInitialProducts(for: selectedCategory)
                            }
                        }
                }
            }
        }
    }

    private func productList() -> some View {
        VStack {
            let products = viewModel.productViewModel.products

            if products.isEmpty, !isFetching {
                Text("В этой категории пока нет товаров.")
                    .padding()
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else {
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 1), GridItem(.flexible(), spacing: 1)], spacing: 1) {
                    ForEach(products, id: \.id) { product in
                        ProductGridView(viewModel: viewModel,
                                        products: [product],
                                        onFavoriteToggle: { _ in })
                            .id(product.id)
                            .onAppear {
                                if product == products.last, hasMoreData {
                                    loadMoreProducts()
                                }
                            }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            if isFetching {
                ProgressView("Загрузка...")
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func loadInitialProducts(for category: Category) {
        isFetching = true
        hasMoreData = true
        initialLoadDone = true
        viewModel.productViewModel.resetData()
        viewModel.productViewModel.fetchProducts(for: category) { success in
            DispatchQueue.main.async {
                isFetching = false
                if !success {
                    print("Не удалось загрузить продукты")
                }
                hasMoreData = self.viewModel.productViewModel.nextPageURL != nil
            }
        }
    }

    private func loadMoreProducts() {
        guard !isFetching, hasMoreData, let selectedCategory else { return }

        isFetching = true
        viewModel.productViewModel.fetchProducts(for: selectedCategory) { success in
            DispatchQueue.main.async {
                isFetching = false
                if !success {
                    print("Не удалось загрузить следующую страницу")
                    hasMoreData = false
                } else {
                    hasMoreData = self.viewModel.productViewModel.nextPageURL != nil
                }
            }
        }
    }
}
