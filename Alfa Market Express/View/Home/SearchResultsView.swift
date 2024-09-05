//
//  SearchResultsView.swift
//  WareHouse1
//
//  Created by Said Tapaev on 22.07.2024.
//
import SwiftUI

struct SearchBar: View {
    @State private var searchText: String = ""
   
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    .padding(10)
                
                TextField("Поиск", text: $searchText)
                    .padding(.leading, 10)
            }
            .background(Color(.systemGray6))
            .cornerRadius(5)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.main, lineWidth: 1)
            )
        }
    }
}
