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
                ScrollView {
                    RecommendationCardView(viewModel: viewModel, products: shuffledProducts, categories: viewModel.categoryViewModel.categories)
                    SearchBar(viewModel: viewModel)
                        .padding(.horizontal)
                    
                    VStack {
                        CatalogGridView(viewModel: viewModel)
                        ProductGridView(viewModel: viewModel, products: shuffledProducts) { product in

                        }
                    }
                }
            }
            .background(.colorGray)
            .onAppear {
                print("HomeView загружен.)")
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
