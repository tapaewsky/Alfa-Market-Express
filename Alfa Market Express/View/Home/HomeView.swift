//
//  HomeView.swift
//  WareHouse1
//
//  Created by Said Tapaev on 06.07.2024.
//
import SwiftUI
import Combine

struct HomeView: View {
    @StateObject var viewModel: MainViewModel
    @StateObject private var networkMonitor = NetworkMonitor()
    @State private var shuffledProducts: [Product] = []
    @State var isFetching = false

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
            loadData()
        }
    }
    
    private func loadData() {
        isFetching = true
        
     
        let productFetchGroup = DispatchGroup()
        
        productFetchGroup.enter()
        viewModel.productViewModel.fetchProducts { success in
            DispatchQueue.main.async {
                if success {
                    self.updateShuffledProducts()
                    print("Главное успешно загружено")
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
                    print("Слайды успешно загружены")
                } else {
                    print("Не удалось загрузить слайды")
                }
                productFetchGroup.leave()
            }
        }
    }

    private func updateShuffledProducts() {
        shuffledProducts = viewModel.productViewModel.products.shuffled()
    }
}
        
