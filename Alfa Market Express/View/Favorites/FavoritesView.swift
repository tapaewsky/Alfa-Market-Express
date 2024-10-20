//
//  FavoritesView.swift
//  WareHouse1
//
//  Created by Said Tapaev on 06.07.2024.
//
import SwiftUI
import Kingfisher
import Combine

struct FavoritesView: View {
    @ObservedObject var viewModel: MainViewModel
    @State private var isFetching: Bool = false

    var body: some View {
        VStack {
            HeaderView {
                SearchBar(viewModel: viewModel)
                    
            }

            ScrollView {
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
                    print("Избранное успешно загружено")
                } else {
                    print("Не удалось загрузить избранное")
                }
            }
        }
    }
}

struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesView(viewModel: MainViewModel())
    }
}
