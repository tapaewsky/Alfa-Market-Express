//
//  FavoritesView.swift
//  AlfaMarketExpress
//
//  Created by Said Tapaev on 24.12.2024.
//

import SwiftUI
import Kingfisher
import Combine

struct FavoritesView: View {
    @ObservedObject var viewModel: MainViewModel
    @State private var isFetching: Bool = false
    @StateObject var networkMonitor: NetworkMonitor = NetworkMonitor()

    var body: some View {
        VStack {
            
                SearchBar(viewModel: viewModel)
            

            ScrollView {
                if networkMonitor.isConnected {
                    if viewModel.favoritesViewModel.favorites.isEmpty && !isFetching {
                        Text("Нет избранных товаров")
                            .padding()
                            .foregroundColor(.gray)
                    } else {
                        VStack {
                            ForEach(viewModel.favoritesViewModel.favorites, id: \.id) { product in
                                NavigationLink(destination: ProductDetailView(viewModel: viewModel, product: product)) {
                                    FavoritesCardView(product: product, viewModel: viewModel)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding(.vertical, 2)
                                .padding(.horizontal, 15)
                            }
                        }
                    }
                } else {
                    NoInternetView(viewModel: viewModel)
                        .padding()
                }
            }
            .onAppear {
                loadFavorites()
            }
        }
    }

    private func loadFavorites() {
        isFetching = true
        viewModel.favoritesViewModel.fetchFavorites { success in
            DispatchQueue.main.async {
                isFetching = false
                if success {
                } else {
                    print("Не удалось загрузить избранное")
                }
            }
        }
    }
}
