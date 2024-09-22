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
                    ScrollView {
                        RecommendationCardView(viewModel: viewModel, categories: viewModel.categoryViewModel.categories)
                        SearchBar()
                            .padding(.horizontal)
                        
                        VStack {
                            CatalogGridView(viewModel: viewModel)
                            ProductGridView(
                                viewModel: viewModel,
                                onFavoriteToggle: { product in
                                    Task {
                                        await viewModel.favoritesViewModel.toggleFavorite(for: product)
                                        print("\(product.name) теперь \(viewModel.favoritesViewModel.isFavorite(product) ? "в избранном" : "не в избранном")")
                                    }
                                }
                            )
                        }
                    }
                }
            }
            .onAppear {
                print("HomeView загружен. Текущие избранные: \(viewModel.favoritesViewModel.favorites.map { $0.name })")
            }
        }
    }
}
