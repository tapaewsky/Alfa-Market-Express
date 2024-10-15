//
//  HomeView.swift
//  WareHouse1
//
//  Created by Said Tapaev on 06.07.2024.
//
import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: MainViewModel
    @StateObject private var networkMonitor = NetworkMonitor()
    @State private var shuffledProducts: [Product] = []
   
    var body: some View {
        NavigationView {
            VStack {
                if !networkMonitor.isConnected {
                    Text("Пожалуйста, проверьте соединение с интернетом.")
                        .foregroundColor(.red)
                }

                ScrollView {
                    if viewModel.slideViewModel.slides.isEmpty {
                        ProgressView("Загрузка слайдов...")
                    } else {
                        RecommendationCardView(viewModel: viewModel, slide: viewModel.slideViewModel.slides)
                    }
                    
                    SearchBar(viewModel: viewModel)
                        .padding(.horizontal)

                    if shuffledProducts.isEmpty {
                        ProgressView("Загрузка продуктов...")
                    } else {
                        ProductGridView(viewModel: viewModel, products: shuffledProducts) { product in
                            // Действия при выборе продукта
                        }
                    }
                }
            }
            .onAppear {
                print("HomeView загружен.")
                viewModel.slideViewModel.fetchSlides { _ in }
                viewModel.productViewModel.fetchProducts { _ in }
                shuffleProductsIfNeeded()
            }
        }
    }
    
    private func shuffleProductsIfNeeded() {
        if !viewModel.productViewModel.products.isEmpty {
            shuffledProducts = viewModel.productViewModel.products.shuffled()
        }
    }
}
