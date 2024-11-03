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
    @State private var isLoading: Bool = false
    @FocusState private var isSearchFieldFocused: Bool
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    .padding(11)
                                
                TextField("Поиск", text: $viewModel.searchViewModel.searchText)
                    .padding(.vertical, 10)
                    .focused($isSearchFieldFocused)
                    .onSubmit {
                        performSearch()
                    }
                    .onChange(of: isSearchFieldFocused) { isFocused in
                        if !isFocused {
                            clearSearch()
                        }
                    }
                if isSearching {
                    Button(action: {
                        clearSearch()
                    }) {
                        Image(systemName: "eraser.fill")
                            .foregroundColor(.gray)
                            .padding(11)
                    }
                }
            }
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 1)
            .padding()
                        
            if isLoading {
            }
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
struct SearchResultsView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewModel: MainViewModel
    var products: [Product]
    var onFavoriteToggle: (Product) -> Void
    
    var body: some View {
        ScrollView {
            if viewModel.searchViewModel.products.isEmpty {
                Text("По вашему запросу ничего не найдено.")
                    .padding()
                    .foregroundColor(.gray)
            } else {
                ProductGridView(viewModel: viewModel, products: products, onFavoriteToggle: onFavoriteToggle)
            }
        }
        .navigationTitle("Результаты поиска")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(leading: CustomBackButton() {
            self.presentationMode.wrappedValue.dismiss()
        })
        .navigationBarBackButtonHidden(true)
    }
}
