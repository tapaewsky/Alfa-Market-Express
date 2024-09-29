//
//  SearchResultsView.swift
//  WareHouse1
//
//  Created by Said Tapaev on 22.07.2024.
//
import SwiftUI

struct SearchBar: View {
    @ObservedObject var viewModel: MainViewModel
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
                .padding(11)
            
            TextField("Поиск", text: $viewModel.productViewModel.searchText)
                .padding(.vertical, 10)
        }
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 1)
    }
}
