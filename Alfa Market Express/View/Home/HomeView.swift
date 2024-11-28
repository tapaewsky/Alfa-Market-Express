//
//  HomeView.swift
//  WareHouse1
//
//  Created by Said Tapaev on 06.07.2024.
//
//import SwiftUI
//import Combine
//
//struct HomeView: View {
//    @StateObject var viewModel: MainViewModel
//    @StateObject private var networkMonitor = NetworkMonitor()
//    @State private var shuffledProducts: [Product] = []
//    @State private var currentPage: Int = 1
//    @State var isFetching = false
//  
//    var body: some View {
//        NavigationView {
//            ZStack {
//                ScrollView(showsIndicators: false) {
//                    SlidesCardView(viewModel: viewModel)
//                    SearchBar(viewModel: viewModel)
//                    ProductGridView(viewModel: viewModel, products: shuffledProducts, onFavoriteToggle: { _ in })
//                        .padding(.vertical)
//                }
//            }
//        }
//        .navigationBarBackButtonHidden(true)
//        .onAppear {
//            loadProducts()
//        }
//    }
//    
//    private func loadProducts() {
//        isFetching = true
//        let productFetchGroup = DispatchGroup()
//        
//        productFetchGroup.enter()
//        viewModel.productViewModel.fetchProducts() { success in
//            DispatchQueue.main.async {
//                if success {
//                    self.updateShuffledProducts()
//                } else {
//                    print("Не удалось загрузить главное")
//                }
//                productFetchGroup.leave()
//            }
//        }
//        
//        productFetchGroup.enter()
//        viewModel.slideViewModel.fetchSlides { success in
//            DispatchQueue.main.async {
//                if success {
//                } else {
//                    print("Не удалось загрузить слайды")
//                }
//                productFetchGroup.leave()
//            }
//        }
//    }
//
//    private func updateShuffledProducts() {
//        shuffledProducts = viewModel.productViewModel.products.shuffled()
//    }
//}
import SwiftUI

struct HomeView: View {
    @StateObject var viewModel: MainViewModel
    @State private var isFetching: Bool = false
    @State private var hasMoreData: Bool = true
    @State private var currentPage: Int = 1
    @State private var shuffledProducts: [Product] = []


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
            }
            .navigationBarBackButtonHidden(true)
            .onAppear {
                loadInitialProducts()
                
            }
        }
    private var productList: some View {
        ScrollView {
            LazyVStack {
                if shuffledProducts.isEmpty && !isFetching {
                    Text("Нет доступных продуктов.")
                        .padding()
                } else {
                    ProductGridView(
                        viewModel: viewModel,
                        products: shuffledProducts,
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
                                if !isFetching {
                                    if proxy.frame(in: .global).maxY <= UIScreen.main.bounds.height {
                                        print("Загружаем следующую страницу... Текущая страница: \(currentPage)")
                                        loadMoreProducts()
                                    }
                                }
                            }
                    }
                    .frame(height: 1)
                }
            }
        }
    }
    
    private func loadInitialProducts() {
            isFetching = true
            let productFetchGroup = DispatchGroup()
    
            productFetchGroup.enter()
            viewModel.productViewModel.fetchProducts() { success in
                DispatchQueue.main.async {
                    if success {
                        self.updateShuffledProducts()
                    } else {
                        print("Не удалось загрузить главное")
                    }
                    productFetchGroup.leave()
                }
            }
    
            productFetchGroup.enter()
            viewModel.slideViewModel.fetchSlides { success in
                DispatchQueue.main.async {
                    if success {
                    } else {
                        print("Не удалось загрузить слайды")
                    }
                    productFetchGroup.leave()
                }
            }
        }

    private func loadMoreProducts() {
        guard !isFetching else { return }
        isFetching = true
        viewModel.productViewModel.fetchProducts { success in
            DispatchQueue.main.async {
                if success {
                    updateShuffledProducts()
                    currentPage += 1
                } else {
                    print("Не удалось загрузить следующую страницу")
                    hasMoreData = false
                }
                isFetching = false
            }
        }
    }

    private func updateShuffledProducts() {
        shuffledProducts = viewModel.productViewModel.products
    }
}
