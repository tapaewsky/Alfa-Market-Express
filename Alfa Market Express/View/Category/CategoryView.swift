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
    }
}

struct CategoryView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryView(viewModel: MainViewModel())
    }
}
