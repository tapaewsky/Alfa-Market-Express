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
        VStack() {
            Text(category.name)
                .font(.headline)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .foregroundColor(.primary)
                .padding(.trailing, 50)
            
            Spacer()
            
            ZStack() {
                if let imageUrl = category.imageUrl, let url = URL(string: imageUrl) {
                    KFImage(url)
                        .placeholder {
                            ProgressView()
                                .frame(width: 100,height: 100)
                        }
                        .resizable()
                        .scaledToFit() 
                        .frame(width: 150,height: 90)
                        .cornerRadius(10)
                        .aspectRatio(contentMode: .fill)
                        .clipped()
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 150)
                        .cornerRadius(10)
                        .clipped()
                }
            }
          
        }
        .padding()
        .background(Color.colorGray)
        .cornerRadius(15)
    }
}
