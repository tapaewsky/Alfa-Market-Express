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
    @State private var showSearchResults: Bool = false // Для показа нового экрана
   
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    .padding(11)

                TextField("Поиск", text: $viewModel.searchViewModel.searchText, onCommit: {
                   
                    if !viewModel.searchViewModel.searchText.isEmpty {
                        viewModel.searchViewModel.filteredProducts
                        showSearchResults = true
                    }
                })
                .padding(.vertical, 10)
                .onChange(of: viewModel.searchViewModel.searchText) { newValue in
                    isSearching = !newValue.isEmpty
                    if !newValue.isEmpty {
                        viewModel.searchViewModel.searchProducts(query: newValue)
                    }
                }

                if isSearching {
                    Button(action: {
                        viewModel.searchViewModel.searchText = ""
                        isSearching = false
                        viewModel.searchViewModel.filteredProducts
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

           
            NavigationLink(destination: SearchResultsView(
                viewModel: viewModel,
                products: viewModel.searchViewModel.filteredProducts,
                onFavoriteToggle: { product in
                    viewModel.productViewModel
                }), isActive: $showSearchResults) {
                EmptyView()
            }
        }
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
                .navigationBarItems(leading: CustomBackButton(label: "Назад", color: .colorGreen) {
                    self.presentationMode.wrappedValue.dismiss()
                })

        }
        .navigationBarBackButtonHidden(true)
    }
}
