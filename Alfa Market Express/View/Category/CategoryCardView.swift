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
            Text(category.name)
                .font(.subheadline)
                .fontWeight(.bold)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding([.leading, .trailing, .top], 10)
            
            Spacer()
            
            ZStack(alignment: .topTrailing) {
                if let imageUrl = category.imageUrl, let url = URL(string: imageUrl) {
                    KFImage(url)
                        .placeholder {
                            ProgressView()
                                .frame(width: 150, height: 150)
                        }
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(10)
                        .clipped()
                        .aspectRatio(1, contentMode: .fit)
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(10)
                        .clipped()
                        .aspectRatio(1, contentMode: .fit)
                }
            }
        }
        .padding()
        .background(Color.colorGray)
        .cornerRadius(15)
        .aspectRatio(1, contentMode: .fit)
    }
}
