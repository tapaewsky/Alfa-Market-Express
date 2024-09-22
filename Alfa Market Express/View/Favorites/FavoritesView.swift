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
    @State private var searchText = ""
    @State private var isFetching = false

    var body: some View {
        VStack {
            HeaderView {
                SearchBar()
                    .padding(.horizontal)
            }
            ScrollView {
                if viewModel.favoritesViewModel.favorites.isEmpty && !isFetching {
                    Text("Нет избранных товаров")
                        .padding()
                        .foregroundColor(.gray)
                } else {
                    ForEach(viewModel.favoritesViewModel.favorites.filter { searchText.isEmpty ? true : $0.name.contains(searchText) }, id: \.id) { product in
                        NavigationLink(destination: ProductDetailView(viewModel: viewModel, product: product)) {
                            FavoritesCardView(product: product, viewModel: viewModel)
                                .padding(.vertical, 6)
                                .padding(.horizontal, 8)
                        }
                    }
                }
            }
        }
        .onAppear {
            loadFavorites()
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
