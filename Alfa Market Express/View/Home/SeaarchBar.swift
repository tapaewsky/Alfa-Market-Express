//
//  SearchResultsView.swift
//  WareHouse1
//
//  Created by Said Tapaev on 22.07.2024.
//
import SwiftUI

struct SearchBar: View {
    @ObservedObject var viewModel: MainViewModel
    @State private var isSearching: Bool = false
    @State private var showSearchResults: Bool = false

    var body: some View {
        VStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    .padding(11)

                TextField("Поиск", text: $viewModel.searchViewModel.searchText)
                    .padding(.vertical, 10)
                    .onSubmit {  // Срабатывает при нажатии Enter
                        performSearch()
                    }

                if isSearching {
                    Button(action: {
                        clearSearch()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                            .padding(11)
                    }
                }
            }
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 1)
            .padding()

            NavigationLink(
                destination: SearchResultsView(
                    viewModel: viewModel,
                    products: viewModel.searchViewModel.filteredProducts,
                    onFavoriteToggle: { product in
                        viewModel.productViewModel
                    }
                ),
                isActive: $showSearchResults
            ) {
                EmptyView()
            }
        }
    }

    // MARK: - Perform Search
    private func performSearch() {
        guard !viewModel.searchViewModel.searchText.isEmpty else { return }
        viewModel.searchViewModel.searchProducts(query: viewModel.searchViewModel.searchText)
        showSearchResults = true
    }

    // MARK: - Clear Search
    private func clearSearch() {
        viewModel.searchViewModel.searchText = ""
        isSearching = false
        viewModel.searchViewModel.products = []  // Очистка результатов
    }
}

struct SearchResultsView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewModel: MainViewModel
    var products: [Product]
    var onFavoriteToggle: (Product) -> Void

    var body: some View {
        ScrollView {
            ProductGridView(viewModel: viewModel, products: products, onFavoriteToggle: onFavoriteToggle)
                .navigationTitle("Результаты поиска")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(leading: CustomBackButton() {
                    self.presentationMode.wrappedValue.dismiss()
                })
        }
        .navigationBarBackButtonHidden(true)
    }
}
