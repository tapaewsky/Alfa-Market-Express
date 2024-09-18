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
    
    var body: some View {
        NavigationView {
            VStack {
                Group {
//                    HeaderView()
                    ScrollView {
                        RecommendationCardView(viewModel: MainViewModel(), categories: viewModel.categoryViewModel.categories)
                        SearchBar()
                            .padding(.horizontal)
                        
                        if viewModel.productViewModel.isLoading {
                            ProgressView()
                        } else if viewModel.productViewModel.isError {
                            Text("Не удалось загрузить данные. Пожалуйста, проверьте подключение к сети и повторите попытку.")
                                .foregroundColor(.colorRed)
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
                if networkMonitor.isConnected {
                    Task {
                        await fetchData()
                    }
                }
            }
            .onChange(of: networkMonitor.isConnected) { isConnected in
                if isConnected {
                    Task {
                        await fetchData()
                    }
                }
            }
        }
    }
    
    private func fetchData() async {
        viewModel.productViewModel.isLoading = true
        await viewModel.productViewModel.fetchData { success in
            viewModel.productViewModel.isLoading = false
            if !success {
                viewModel.productViewModel.isError = true
            } else {
                viewModel.productViewModel.isError = false
            }
        }
    }
}
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(viewModel: MainViewModel())
    }
}
