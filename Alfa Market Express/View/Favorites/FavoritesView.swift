//
//  FavoritesView.swift
//  WareHouse1
//
//  Created by Said Tapaev on 06.07.2024.
//

import SwiftUI

struct FavoritesView: View {
    @ObservedObject var viewModel: ProductViewModel
    @State private var searchText = ""

    var body: some View {
        VStack(spacing: 10) {
            HeaderView()
            
            Group {
                SearchBar(searchText: $searchText, onSearch: performSearch)
                favoriteText
                favoriteList
            }
            .padding(.horizontal, 16)
        }
        .onChange(of: searchText) { _ in
            performSearch()
        }
    }
    
    private var favoriteText: some View {
        Text("Избранное")
            .font(.title)
            .fontWeight(.bold)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var favoriteList: some View {
        List {
            ForEach(viewModel.filteredFavorites) { product in
                NavigationLink(destination: ProductDetailView(viewModel: viewModel, product: product)) {
                    HStack(spacing: 10) {
                        AsyncImage(url: URL(string: product.imageUrl ?? "")) { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 50, height: 50)
                                .cornerRadius(8)
                        } placeholder: {
                            ProgressView()
                                .frame(width: 50, height: 50)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(product.name)
                                .font(.headline)
                                .lineLimit(1)
                            
                            Text("\(product.price) ₽")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        .listStyle(.plain)
    }
    
    private func performSearch() {
        viewModel.updateSearchText(searchText)
    }
}

struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesView(viewModel: ProductViewModel())
    }
}
