//
//  CategoryCardView.swift
//  AlfaMarketExpress
//
//  Created by Said Tapaev on 24.12.2024.
//

import SwiftUI
import Kingfisher

struct CategoryCardView: View {
    let category: Category
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            if let imageUrl = category.imageUrl, let url = URL(string: imageUrl) {
                KFImage(url)
                    .placeholder {
                        ProgressView()
                            .frame(width: 150, height: 150)
                    }
                    .resizable()
                    .scaledToFit()
                    .clipped()
                    .padding(0)
            } else {
                Image("placeholderCategory")
                    .resizable()
                    .scaledToFit()
                    .clipped()
                    .aspectRatio(contentMode: .fit)
            }
            
            Text(category.name)
                .font(.subheadline)
                .fontWeight(.bold)
                .lineLimit(1)
                .foregroundColor(.primary)
                .padding(5)
               
               
        }
        .padding(0)
        .background(Color("colorGray"))
        .cornerRadius(15)
    }
}

