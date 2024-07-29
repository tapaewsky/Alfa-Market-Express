//
//  CatalogView.swift
//  WareHouse1
//
//  Created by Said Tapaev on 06.07.2024.
//
import SwiftUI

struct CatalogView: View {
    @ObservedObject var viewModel: ProductViewModel
    @State private var searchText = ""
    private let customGreen = Color(red: 38 / 255, green: 115 / 255, blue: 21 / 255)

    var body: some View {
        VStack(spacing: 0 ) {
            
            
        
            HeaderView(viewModel: viewModel, customGreen: customGreen)
            
            
            
            
            SearchBar(searchText: $searchText, customGreen: customGreen, viewModel: viewModel)
                .padding(.vertical)
                .padding(.horizontal)
            
            
            
            ScrollView {
                CategoryGridView(viewModel: viewModel)
                    .padding()
            
                
            }
            
            
        }
        .environmentObject(viewModel)
        
    }
}

struct CatalogView_Previews: PreviewProvider {
    static var previews: some View {
        CatalogView(viewModel: ProductViewModel())
    }
}
