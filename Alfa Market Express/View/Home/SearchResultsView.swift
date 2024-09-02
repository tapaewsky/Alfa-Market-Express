//
//  SearchResultsView.swift
//  WareHouse1
//
//  Created by Said Tapaev on 22.07.2024.
//
import SwiftUI

struct SearchView: View {
    @ObservedObject var viewModel: ProductViewModel
    @State private var searchText: String = ""

    var body: some View {
        VStack {
            SearchBar(searchText: $searchText, onSearch: performSearch)
                .padding()

            if viewModel.isLoading {
                ProgressView()
            } else {
                List {
                    ForEach(viewModel.filteredProducts) { product in
                        ProductRowView(product: product, viewModel: viewModel, onFavoriteToggle: {
                            viewModel.toggleFavorite(product)
                        })
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
        .onChange(of: searchText) { newValue in
            performSearch()
        }
        .onAppear {
            viewModel.fetchData { _ in }
        }
    }

    private func performSearch() {
        viewModel.searchProducts(query: searchText) { success in
            if !success {
                print("Search failed")
            }
        }
    }
}


struct SearchBar: View {
    @Binding var searchText: String
    var onSearch: () -> Void

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
                .padding(10)
            
            TextField("Поиск", text: $searchText, onEditingChanged: { _ in
                onSearch()
            })
            .padding(.leading, 10)
            
            Button(action: {
                onSearch()
            }) {
                Text("Поиск")
                    .padding(.trailing, 10)
            }
        }
        .background(Color(.systemGray6))
        .cornerRadius(5)
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(Color.blue, lineWidth: 1)
        )
    }
}
