//
//  CatalogView.swift
//  WareHouse1
//
//  Created by Said Tapaev on 06.07.2024.
//
import SwiftUI
import Kingfisher

struct CategoryView: View {
    @ObservedObject var viewModel: MainViewModel
    @State var isFetching: Bool = false
    
    var body: some View {
        VStack {
            HeaderView {
                SearchBar(viewModel: viewModel)
                    .padding(.horizontal)
            }
            ScrollView {
                CategoryGridView(viewModel: viewModel)
                    .padding()
            }
        }
        .onAppear {
            loadCart()
           
        }
    }
        
    
    private func loadCart() {
        isFetching = true
        viewModel.categoryViewModel.fetchCategory { success in
            DispatchQueue.main.async {
                isFetching = false
                if success {
                    print("Избранное успешно загружена")
                } else {
                    print("Не удалось загрузить избранное")
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
