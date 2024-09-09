//
//  HomeView.swift
//  WareHouse1
//
//  Created by Said Tapaev on 06.07.2024.
//
import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = MainViewModel()
    @StateObject private var networkMonitor = NetworkMonitor()
    @State private var hasLoadedData: Bool = false

    var body: some View {
        NavigationView {
            VStack {
                Group {
                    HeaderView()
                    ScrollView {
                        RecommendationCardView(categories: viewModel.categoryViewModel.categories)
                        SearchBar()
                            .padding(.horizontal)
                        
                        if viewModel.productViewModel.isLoading {
                            ProgressView()
                        } else if viewModel.productViewModel.isError {
                            Text("Не удалось загрузить данные. Пожалуйста, проверьте подключение к сети и повторите попытку.")
                                .foregroundColor(.red)
                        } else {
                            VStack {
                                CatalogGridView(viewModel: viewModel)
                                ProductGridView(
                                    viewModel: viewModel.productViewModel,
                                    cartViewModel: viewModel.cartViewModel,
                                    favoritesViewModel: viewModel.favoritesViewModel,
                                    onFavoriteToggle: { product in
                                        viewModel.favoritesViewModel.toggleFavorite(product)
                                    }
                                )
                            }
                        }
                    }
                }
            }
            .onAppear {
                if !hasLoadedData {
                    loadData()
                }
            }
            .onChange(of: networkMonitor.isConnected) { isConnected in
                if isConnected && !hasLoadedData {
                    Task {
                        await fetchData()
                    }
                }
            }
        }
    }

    private func loadData() {
        if networkMonitor.isConnected {
            print("Network is connected, loading data...")
            Task {
                await fetchData()
            }
        } else {
            viewModel.productViewModel.isError = true
        }
    }

    private func fetchData() async {
        viewModel.productViewModel.isLoading = true
        let success = await withCheckedContinuation { continuation in
            viewModel.productViewModel.fetchData { success in
                continuation.resume(returning: success)
            }
        }
        viewModel.productViewModel.isLoading = false
        hasLoadedData = true
        viewModel.productViewModel.isError = !success
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
