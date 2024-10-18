//
//  HomeView.swift
//  WareHouse1
//
//  Created by Said Tapaev on 06.07.2024.
//
import SwiftUI
import Combine

struct HomeView: View {
    @ObservedObject var viewModel: MainViewModel
    @StateObject private var networkMonitor = NetworkMonitor()
    @State private var shuffledProducts: [Product] = []
    @State var isFetching: Bool = false

    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    RecommendationCardView(viewModel: viewModel)
                    SearchBar(viewModel: viewModel)
                       
                    
                    ProductGridView(viewModel: viewModel, products: shuffledProducts, onFavoriteToggle: { _ in })
                       
                        .padding(.vertical)
                }
            }
        }
        .onAppear {
            loadCart()
            updateShuffledProducts()
        }
    }
    private func loadCart() {
        isFetching = true
        viewModel.productViewModel.fetchProducts { success in
            DispatchQueue.main.async {
                isFetching = false
                if success {
                    print("Избранное успешно загружена")
                } else {
                    print("Не удалось загрузить избранное")
                }
            }
        }
    }
    private func updateShuffledProducts() {
        shuffledProducts = viewModel.productViewModel.products.shuffled()
    }
}
