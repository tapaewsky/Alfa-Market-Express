//
//  CategoryView 2.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 19.10.2024.
//


import SwiftUI
import Kingfisher

struct CategoryView: View {
    @StateObject var viewModel: MainViewModel
    @State var isFetching: Bool = false

    var body: some View {
        VStack {
            HeaderView {
                SearchBar(viewModel: viewModel)
                    .padding(.horizontal)
            }
            ScrollView {
                if isFetching {
                    ProgressView()
                        .padding()
                } else if viewModel.categoryViewModel.categories.isEmpty {
                    Text("Нет доступных категорий")
                        .padding()
                } else {
                    CategoryProductsView(viewModel: viewModel) // Отображение категорий
                }
            }
            .padding(.top)
        }
        .onAppear {
            loadCategories()
        }
    }

    private func loadCategories() {
        isFetching = true
        
        viewModel.categoryViewModel.fetchCategory { success in
            DispatchQueue.main.async {
                isFetching = false
                if success {
                    print("Категории успешно загружены: \(self.viewModel.categoryViewModel.categories)")
                    self.loadProducts() // Загружаем продукты
                } else {
                    print("Не удалось загрузить категории")
                }
            }
        }
    }
    
    private func loadProducts() {
        viewModel.productViewModel.fetchProducts { success in
            if success {
                print("Продукты успешно загружены: \(self.viewModel.productViewModel.products)")
            } else {
                print("Не удалось загрузить продукты")
            }
        }
    }
}