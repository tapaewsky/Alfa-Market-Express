//
//  CatalogView.swift
//  WareHouse1
//
//  Created by Said Tapaev on 06.07.2024.
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
                    if viewModel.categoryViewModel.categories.isEmpty && !isFetching {
                        Text("Нет доступных категорий")
                            .padding()
                    } else {
                        CategoryGridView(viewModel: viewModel)
                            .padding()
                    }
                }
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
                    print("Категории успешно загружены")
                } else {
                    print("Не удалось загрузить категории")
                }
            }
        }
    }
}

struct CategoryView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryView(viewModel: MainViewModel())
    }
}
