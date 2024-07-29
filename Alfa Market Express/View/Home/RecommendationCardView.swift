//
//  RecommendationCardView.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 25.07.2024.
//

import SwiftUI

struct RecommendationCardView: View {
    let category: Category
    let onCategorySelected: (Category) -> Void

    var body: some View {
        AsyncImage(url: URL(string: category.imageUrl)) { image in
            image
                .resizable()
                .frame(width: 350, height: 100)
                .clipped()
                .cornerRadius(8)
        } placeholder: {
            ProgressView()
                .frame(width: 350, height: 100)
                
                .cornerRadius(8)
        }
        .onTapGesture {
            onCategorySelected(category)
        }
        .shadow(radius: 10)
    }
}

struct RecommendationCardView_Previews: PreviewProvider {
    static var previews: some View {
        RecommendationCardView(category: Category(id: 1, name: "Sample Category", description: "", imageUrl: "https://via.placeholder.com/150")) { _ in }
    }
}
