//
//  CatalogView.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 07.09.2024.
//

import SwiftUI

struct CatalogView: View {
    
    let category: Category
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: category.imageUrl)) { image in
                image.resizable()
            } placeholder: {
                ProgressView()
            }
            .aspectRatio(contentMode: .fill)
            .shadow(radius: 5)
            .clipped()

            Text(category.name)
                .font(.headline)
                
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .foregroundColor(.primary)

           

            
            
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        
    }
}

   

