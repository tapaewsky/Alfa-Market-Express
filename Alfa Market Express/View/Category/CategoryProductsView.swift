//
//  CategoryProductsView.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 29.07.2024.
//

import SwiftUI

struct CategoryProductsView: View {
    @StateObject var viewModel: MainViewModel
    @State private var selectedCategory: Category? = nil
    @State private var isFetching: Bool = false
    @State private var hasMoreData: Bool = true
    @State private var currentPage: Int = 1
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            if let category = selectedCategory {
                backButton
                productList(for: category)
            } else {
                categoryGrid
            }
        }
    }

    private var backButton: some View {
        HStack {
            Button(action: {
                selectedCategory = nil
            }) {
                HStack {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.colorGreen)
                    Text("Назад")
                        .foregroundColor(.black)
                }
            }
            .padding()

            Spacer()
        }
    }

    private func productList(for category: Category) -> some View {
        ScrollView {
            LazyVStack {
                let filteredProducts = category.id == 0
                    ? viewModel.productViewModel.products
                    : viewModel.productViewModel.products.filter { $0.category == category.id }
                
                if filteredProducts.isEmpty && !isFetching {
                    Text("Нет доступных продуктов для категории: \(category.name)")
                        .padding()
                } else {
                    ProductGridView(
                        viewModel: viewModel,
                        products: filteredProducts,
                        onFavoriteToggle: { _ in }
                    )
                }

                if isFetching {
                    ProgressView()
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .center)
                }

                if hasMoreData {
                    GeometryReader { proxy in
                        Color.clear
                            .frame(height: 1)
                            .onAppear {
                                if !isFetching {
                                    if proxy.frame(in: .global).maxY <= UIScreen.main.bounds.height {
                                        print("Загружаем следующую страницу... Текущая страница: \(currentPage)")
                                        loadMoreProducts(for: category)
                                    }
                                }
                            }
                    }
                    .frame(height: 1)
                }
            }
        }
    }

    private func loadMoreProducts(for category: Category) {
        guard !isFetching else {
            print("Загрузка уже в процессе, пропускаем запрос")
            return
        }
        
        isFetching = true
        print("Начинаем загрузку... Страница: \(currentPage), категория: \(category.name)")

        viewModel.productViewModel.fetchProducts() { success in
            DispatchQueue.main.async {
                if success {
                    print("Загрузка успешна. Страница \(currentPage) подгружена.")
                    hasMoreData = viewModel.productViewModel.baseURL != nil
                    currentPage += 1
                } else {
                    print("Ошибка при загрузке. Остановили пагинацию.")
                    hasMoreData = false
                }
                isFetching = false
            }
        }
    }

    private var categoryGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 1)], spacing: 10) {
            ForEach(viewModel.categoryViewModel.categories, id: \.id) { category in
                Button(action: {
                    selectedCategory = category
                    currentPage = 1
                    hasMoreData = true
                    isFetching = false
                    print("Категория выбрана: \(category.name)")
                }) {
                    CategoryCardView(category: category)
                }
            }
        }
        .padding()
    }
}
