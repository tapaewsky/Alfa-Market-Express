//
//  HomeVIew.swift
//  AlfaMarketExpress
//
//  Created by Said Tapaev on 24.12.2024.
//

import SwiftUI

struct HomeView: View {
    @StateObject var viewModel: MainViewModel
    @StateObject var networkMonitor: NetworkMonitor = .init()

    @State private var isFetching: Bool = false
    @State private var hasMoreData: Bool = true
    @State private var currentPage: Int = 1

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    SearchBar(viewModel: viewModel)

                    if networkMonitor.isConnected {
                        SlidesCardView(viewModel: viewModel)
                        productList
                    } else {
                        NoInternetView(viewModel: viewModel)
                            .padding()
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .onAppear {
                loadInitialProducts()
            }
        }
    }

    private var productList: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 1), GridItem(.flexible(), spacing: 1)], spacing: 1) {
            if viewModel.productViewModel.products.isEmpty, !isFetching {
                Text("Нет доступных продуктов.")
                    .padding()
            } else {
                ForEach(viewModel.productViewModel.products, id: \.id) { product in
                    ProductGridView(viewModel: viewModel,
                                    products: [product],
                                    onFavoriteToggle: { _ in })
                        .onAppear {
                            if product == viewModel.productViewModel.products.last, hasMoreData {
                                loadMoreProducts()
                            }
                        }
                }
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

    private func loadInitialProducts(isRefreshing _: Bool = false) {
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

        group.enter()
        viewModel.slideViewModel.fetchSlides { success in
            DispatchQueue.main.async {
                if !success {
                    print("Не удалось загрузить слайды")
                }
                group.leave()
            }
        }
        group.notify(queue: .main) {
            isFetching = false
        }
    }
}
