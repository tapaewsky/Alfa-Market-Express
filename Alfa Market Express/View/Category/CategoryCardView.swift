//
//  CategoryCardView.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 29.07.2024.
//

import SwiftUI
import Kingfisher

struct CategoryCardView: View {
    let category: Category

    var body: some View {
        VStack {
            KFImage(URL(string: category.imageUrl))
                
                .placeholder {
                    ProgressView()
                }
                .resizable()
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
