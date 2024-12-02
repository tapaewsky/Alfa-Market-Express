//
//  HomeView.swift
//  WareHouse1
//
//  Created by Said Tapaev on 06.07.2024.
//

import SwiftUI

struct HomeView: View {
    @StateObject var viewModel: MainViewModel
    @State private var isFetching: Bool = false
    @State private var hasMoreData: Bool = true
    @State private var currentPage: Int = 1
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView(showsIndicators: false) {
                    SlidesCardView(viewModel: viewModel)
                    SearchBar(viewModel: viewModel)
                    productList
                        .padding(.vertical)
                }
            }
            .navigationBarBackButtonHidden(true)
            .onAppear {
                loadInitialProducts()
            }
        }
    }

    private var productList: some View {
        LazyVStack {
            if viewModel.productViewModel.products.isEmpty && !isFetching {
                Text("Нет доступных продуктов.")
                    .padding()
            } else {
                ProductGridView(
                    viewModel: viewModel,
                    products: viewModel.productViewModel.products,
                    onFavoriteToggle: { _ in }
                )
            }
            
            if isFetching {
                ProgressView()
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
    
    private func loadInitialProducts() {
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
}
