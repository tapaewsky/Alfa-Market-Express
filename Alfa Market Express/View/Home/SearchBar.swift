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
    @State private var isLoading: Bool = false  // Флаг для отслеживания загрузки
    @FocusState private var isSearchFieldFocused: Bool  // Отслеживание фокуса

    var body: some View {
        VStack {
            HStack {
                // Лупа
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    .padding(11)

                // Текстовое поле для поиска
                TextField("Поиск", text: $viewModel.searchViewModel.searchText)
                    .padding(.vertical, 10)
                    .focused($isSearchFieldFocused)  // Следим за фокусом
                    .onSubmit {
                        performSearch()  // Выполняем поиск при нажатии Enter
                    }
                    .onChange(of: isSearchFieldFocused) { isFocused in
                        if !isFocused {
                            clearSearch()  // Очищаем при потере фокуса
                        }
                    }

                // Фиксик - кнопка очистки
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

            // Индикатор загрузки
            if isLoading {
                ProgressView("Загрузка...")
                    .padding()
            }

            // Переход на экран результатов
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

    // MARK: - Perform Search
    private func performSearch() {
        guard !viewModel.searchViewModel.searchText.isEmpty else { return }
        isLoading = true  // Устанавливаем флаг загрузки

        viewModel.searchViewModel.searchProducts(query: viewModel.searchViewModel.searchText) {
            DispatchQueue.main.async {
                isLoading = false  // Останавливаем загрузку
                showSearchResults = true  // Переходим на экран результатов
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
