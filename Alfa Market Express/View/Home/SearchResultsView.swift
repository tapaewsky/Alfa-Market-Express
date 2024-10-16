//
//  SearchResultsView.swift
//  WareHouse1
//
//  Created by Said Tapaev on 22.07.2024.
//
import SwiftUI

struct SearchBar: View {
    @EnvironmentObject var viewModel: MainViewModel
    @State private var isSearching: Bool = false
    @State private var showSearchResults: Bool = false // Для показа нового экрана

    var body: some View {
        VStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    .padding(11)

                TextField("Поиск", text: $viewModel.productViewModel.searchText, onCommit: {
                    // Переход на новое представление по нажатию клавиши Return
                    if !viewModel.productViewModel.searchText.isEmpty {
                        viewModel.productViewModel.filteredProducts // Фильтрация продуктов
                        showSearchResults = true
                    }
                })
                .padding(.vertical, 10)
                .onChange(of: viewModel.productViewModel.searchText) { newValue in
                    isSearching = !newValue.isEmpty
                }

                if isSearching {
                    Button(action: {
                        viewModel.productViewModel.searchText = ""
                        isSearching = false
                        viewModel.productViewModel.filteredProducts // Очистка фильтрованных продуктов
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

            // Переход на новый экран с результатами поиска
            NavigationLink(destination: SearchResultsView(
                viewModel: viewModel.productViewModel,
                products: viewModel.productViewModel.filteredProducts, // Передаем отфильтрованные продукты
                onFavoriteToggle: { product in
                    viewModel.productViewModel
                }), isActive: $showSearchResults) {
                EmptyView()
            }
        }
    }
}

struct SearchResultsView: View {
    @Environment(\.presentationMode) var presentationMode // Окружение для управления навигацией
    @ObservedObject var viewModel: ProductViewModel
    var products: [Product]
    var onFavoriteToggle: (Product) -> Void
    
    var body: some View {
        ScrollView {
            ProductGridView( products: products, onFavoriteToggle: onFavoriteToggle)
                .navigationTitle("Результаты поиска")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(leading: CustomBackButton(label: "Назад", color: .colorGreen) {
                    // Действие для возврата на предыдущий экран
                    self.presentationMode.wrappedValue.dismiss()
                })

        }
        .navigationBarBackButtonHidden(true)
    }
}
