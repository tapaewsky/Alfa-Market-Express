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
            ZStack {
                if !networkMonitor.isConnected {
                    Text("Пожалуйста, проверьте соединение с интернетом.")
                        .foregroundColor(.red)
                }

                ScrollView {
                    RecommendationCardView(viewModel: viewModel, slide: viewModel.slideViewModel.slides)
                    
                    SearchBar(viewModel: viewModel)
                       

                    if shuffledProducts.isEmpty {
                        ProgressView("Загрузка продуктов...")
                    } else {
                        ProductGridView(viewModel: viewModel, products: shuffledProducts) { product in
                                
                        }
                        .padding(.vertical)
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
