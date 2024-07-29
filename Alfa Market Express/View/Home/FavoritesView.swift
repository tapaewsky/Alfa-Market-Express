//
//  FavoritesView.swift
//  WareHouse1
//
//  Created by Said Tapaev on 06.07.2024.
//

import SwiftUI

struct FavoritesView: View {
    @ObservedObject var viewModel: ProductViewModel
    
    var body: some View {
        NavigationView {
            List(viewModel.favorites) { product in
                NavigationLink(destination: ProductDetailView(viewModel: viewModel, product: product)) {
                    HStack(spacing: 10) {
                        AsyncImage(url: URL(string: product.imageUrl)) { image in
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
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Избранное")
        }
        .environmentObject(viewModel) 
    }
}

struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesView(viewModel: ProductViewModel())
    }
}
