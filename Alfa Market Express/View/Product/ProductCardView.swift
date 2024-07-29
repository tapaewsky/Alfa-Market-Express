//
//   ProductCardView.swift
//  WareHouse1
//
//  Created by Said Tapaev on 06.07.2024.
//

import SwiftUI

struct ProductCardView: View {
    var product: Product
    var viewModel: ProductViewModel
    var onFavoriteToggle: () -> Void
    private let customGreen = Color(red: 38 / 255, green: 115 / 255, blue: 21 / 255)

    var body: some View {
        VStack(alignment: .leading) {
            AsyncImage(url: URL(string: product.imageUrl)) { image in
                image.resizable()
            } placeholder: {
                ProgressView()
            }
            .aspectRatio(contentMode: .fill)
            .cornerRadius(10)
            .clipped()
            .shadow(radius: 2)
            
            
            
                
                Text(String(format: "%.0f₽", Double(product.price) ?? 0))
                    .font(.headline)
                    .foregroundColor(customGreen)
                    .frame(alignment: .leading)
                
                
                Text(product.name)
                    .font(.subheadline)
                    
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .foregroundColor(.primary)
            
                

           

            
            
        }
        
        .background(Color.clear)
        
        
    }
}
