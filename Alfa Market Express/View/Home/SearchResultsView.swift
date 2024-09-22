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
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    .padding(11)
                
                TextField("", text: $searchText)
                    
                   
            }
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 1)
            
            
        }
        
    }
}
