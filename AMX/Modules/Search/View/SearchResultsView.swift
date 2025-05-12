//
//  SearchResultsView.swift
//  AMX
//
//  Created by Said Tapaev on 15.04.2025.
//

import SwiftUI

struct SearchResultsView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewModel: MainViewModel
    var products: [Product]
    var onFavoriteToggle: (Product) -> Void

    var body: some View {
        ScrollView {
            let filteredProducts = viewModel.searchViewModel.products

            if filteredProducts.isEmpty {
                VStack {
                    Spacer()
                    Text("По вашему запросу ничего не найдено.")
                        .padding()
                        .foregroundColor(.gray)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 1), GridItem(.flexible(), spacing: 1)], spacing: 1) {
                    ForEach(filteredProducts, id: \.id) { product in
                        ProductGridView(viewModel: viewModel,
                                        products: [product],
                                        onFavoriteToggle: onFavoriteToggle)
                    }
                }
                .padding(.horizontal, 8)
            }
        }
        .navigationTitle("Результаты поиска")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(leading: CustomBackButton {
            self.presentationMode.wrappedValue.dismiss()
        })
        .navigationBarBackButtonHidden(true)
    }
}
