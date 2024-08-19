//
//  FavoritesView.swift
//  WareHouse1
//
//  Created by Said Tapaev on 06.07.2024.
//

import SwiftUI

struct FavoritesView: View {
    @ObservedObject var viewModel: ProductViewModel
    @ObservedObject var profileViewModel: ProfileViewModel
    @State private var searchText = ""
    private let customGreen = Color(red: 38 / 255, green: 115 / 255, blue: 21 / 255)

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                
                HeaderView(viewModel: viewModel, profileViewModel: profileViewModel, customGreen: customGreen)
                    .padding(.top, 0)
                
                SearchBar(searchText: $searchText, customGreen: customGreen, viewModel: viewModel)
                    .padding(.vertical, 0)
                    .padding(.horizontal, 0)
                
                HStack {
                    Text("Избранное")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.leading, 15)
                    
                    Spacer()
                }
                .padding(.top, 10)

                
                List {
                    ForEach(viewModel.favorites.filter { $0.name.contains(searchText) }) { product in
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
                .listStyle(PlainListStyle())
            }
            
        }
    }
}

struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesView(viewModel: ProductViewModel(), profileViewModel: ProfileViewModel())
    }
}
