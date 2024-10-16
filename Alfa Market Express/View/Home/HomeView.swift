//
//  HomeView.swift
//  WareHouse1
//
//  Created by Said Tapaev on 06.07.2024.
//
import SwiftUI

struct HomeView: View {
    @StateObject var viewModel: MainViewModel
    @StateObject private var networkMonitor = NetworkMonitor()
    @State private var shuffledProducts: [Product] = []

    var body: some View {
        NavigationView {
            ZStack {
                if !networkMonitor.isConnected {
                    Text("Пожалуйста, проверьте соединение с интернетом.")
                        .foregroundColor(.red)
                } else {
                    ScrollView {
                        RecommendationCardView(viewModel: viewModel)
                          

                        SearchBar()
                            .environmentObject(viewModel)
                       
                        if shuffledProducts.isEmpty {
                            ProgressView("Загрузка продуктов...")
                        } else {
                            ProductGridView(products: shuffledProducts, onFavoriteToggle: {_ in })
                                .environmentObject(viewModel)
                                .padding(.vertical)
                        }
                    }
                }
            }
            .onAppear {
                print("HomeView загружен.")
                loadProductsIfNeeded()
                shuffleProductsIfNeeded()
            }
        }
    }

    private func loadProductsIfNeeded() {
        if viewModel.productViewModel.products.isEmpty {
            viewModel.productViewModel.fetchData()
        } else {
            shuffledProducts = viewModel.productViewModel.products.shuffled()
        }
    }

    private func shuffleProductsIfNeeded() {
        if !viewModel.productViewModel.products.isEmpty {
            shuffledProducts = viewModel.productViewModel.products.shuffled()
        }
    }
}
