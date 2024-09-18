//
//  FavoritesView.swift
//  WareHouse1
//
//  Created by Said Tapaev on 06.07.2024.
//

import SwiftUI
import Kingfisher

struct FavoritesView: View {
    @ObservedObject var viewModel: ProductViewModel
    @ObservedObject var cartViewModel: CartViewModel
    @ObservedObject var favoritesViewModel: FavoritesViewModel
    @State private var searchText = ""
    
    var body: some View {
        VStack {
            Group {
                favoriteText
                favoriteList
            }
            .padding(.horizontal, 16)
        }
        .onChange(of: searchText) { _ in
            
        }
    }
    
    private var favoriteText: some View {
        Text("Избранное")
            .font(.title)
            .fontWeight(.bold)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var favoriteList: some View {
        
        List(favoritesViewModel.favorites.filter { product in
            searchText.isEmpty || product.name.lowercased().contains(searchText.lowercased())
        }) { product in
            NavigationLink(destination: ProductDetailView(viewModel: viewModel, cartViewModel: cartViewModel, favoritesViewModel: favoritesViewModel, product: product)) {
                HStack(spacing: 10) {
                    KFImage(URL(string: product.imageUrl ?? ""))
                        .placeholder {
                            ProgressView()
                                .frame(width: 50, height: 50)
                        }
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .cornerRadius(8)
                    
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
        .listStyle(.plain)
    }
}

struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesView(viewModel: ProductViewModel(), cartViewModel: CartViewModel(), favoritesViewModel: FavoritesViewModel())
    }
}
