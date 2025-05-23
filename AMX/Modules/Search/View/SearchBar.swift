//
//  SearchBar.swift
//  AlfaMarketExpress
//
//  Created by Said Tapaev on 24.12.2024.
//

import SwiftUI

struct SearchBar: View {
    @ObservedObject var viewModel: MainViewModel
    @State private var isSearching: Bool = false
    @State private var showSearchResults: Bool = false
    @State private var isLoading: Bool = false
    @FocusState private var isSearchFieldFocused: Bool

    var body: some View {
        VStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    .font(.system(size: 24))
                    .padding(15)

                TextField("Поиск", text: $viewModel.searchViewModel.searchText)
                    .bold()
                    .foregroundColor(.black)
                    .font(.system(size: 18, weight: .bold))
                    .padding(.vertical, 15)
                    .focused($isSearchFieldFocused)
                    .tint(Color.gray)
                    .onSubmit {
                        performSearch()
                    }
                    .onChange(of: viewModel.searchViewModel.searchText) { newValue in
                        isSearching = !newValue.isEmpty
                    }

                if isSearching {
                    Button(action: {
                        clearSearch()
                    }) {
                        Image(systemName: "eraser.fill")
                            .foregroundColor(.gray)
                            .padding(15)
                    }
                }
            }
            .background(Color.colorGreen)
            .cornerRadius(25)
            .shadow(radius: 1)
            .opacity(0.9)
            .padding(.horizontal, 10)

            if isLoading {
                ProgressView()
            }

            NavigationLink(destination: SearchResultsView(viewModel: viewModel,
                                                          products: viewModel.searchViewModel.filteredProducts,
                                                          onFavoriteToggle: { _ in
                                                              viewModel.productViewModel
                                                          }),
                           isActive: $showSearchResults)
            {
                EmptyView()
            }
        }
        .onAppear {
            isSearching = !viewModel.searchViewModel.searchText.isEmpty
        }
    }

    private func performSearch() {
        guard !viewModel.searchViewModel.searchText.isEmpty else { return }
        isLoading = true

        viewModel.searchViewModel.searchProducts(query: viewModel.searchViewModel.searchText) {
            DispatchQueue.main.async {
                isLoading = false
                showSearchResults = true
            }
        }
    }

    // MARK: - Clear Search

    private func clearSearch() {
        viewModel.searchViewModel.searchText = ""
        isSearching = false
        viewModel.searchViewModel.products = []
    }
}
