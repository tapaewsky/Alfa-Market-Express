//
//  CatalogView.swift
//  WareHouse1
//
//  Created by Said Tapaev on 06.07.2024.
//
import SwiftUI

struct CatalogView: View {
    @ObservedObject var viewModel: ProductViewModel
    @ObservedObject var profileViewModel: ProfileViewModel
    @State private var searchText = ""
    private let customGreen = Color(red: 38 / 255, green: 115 / 255, blue: 21 / 255)

    var body: some View {
        VStack(spacing: 0 ) {
            
            
        
            HeaderView(viewModel: viewModel, profileViewModel: profileViewModel, customGreen: customGreen)
            
            
            
            
            SearchBar(searchText: $searchText, customGreen: customGreen, viewModel: viewModel)
                .padding(.vertical, 0)
                .padding(.horizontal, 0)
            
            HStack {
                Text("Каталог")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.leading, 15)
                
                Spacer()
            }
            .padding(.top, 10)
            
            
            
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
        CatalogView(viewModel: ProductViewModel(), profileViewModel: ProfileViewModel())
    }
}
