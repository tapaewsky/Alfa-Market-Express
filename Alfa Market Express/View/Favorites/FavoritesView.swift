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

    var body: some View {
        VStack {
            HeaderView {
                SearchBar()
                    .padding(.horizontal)
            }
            ScrollView {
                if viewModel.favoritesViewModel.favorites.isEmpty {
                    Text("Нет избранных товаров")
                        .padding()
                        .foregroundColor(.gray)
                } else {
                    ForEach(viewModel.favoritesViewModel.favorites.filter { searchText.isEmpty || $0.name.contains(searchText) }, id: \.id) { product in
                        NavigationLink(destination: ProductDetailView(viewModel: viewModel, product: product)) {
                            FavoritesCardView(product: product, viewModel: viewModel)
                        }
                    }
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
