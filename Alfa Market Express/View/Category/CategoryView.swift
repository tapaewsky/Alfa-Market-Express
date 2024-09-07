//
//  CatalogView.swift
//  WareHouse1
//
//  Created by Said Tapaev on 06.07.2024.
//
import SwiftUI

struct CategoryView: View {
    @ObservedObject var viewModel: ProductViewModel
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
   
    var body: some View {
        VStack {
            Group {
                HeaderView()
                SearchBar()
                    .padding(.horizontal)
                
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
        }
       
        .environmentObject(viewModel)
          
    }
}

struct CategoryView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryView(viewModel: ProductViewModel())
    }
}
