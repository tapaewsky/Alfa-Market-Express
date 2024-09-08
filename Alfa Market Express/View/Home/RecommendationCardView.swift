//
//  RecommendationCardView.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 25.07.2024.
//

import SwiftUI
import Kingfisher

struct RecommendationCardView: View {
    let categories: [Category]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                ForEach(categories) { category in
                    NavigationLink(destination: CategoryProductsView(viewModel: ProductViewModel(), category: category)) {
                        KFImage(URL(string: category.imageUrl))
                            .placeholder {
                                ProgressView()
                                    .frame(width: 300, height: 150)
                            }
                            .resizable()
                            .scaledToFill()
                            .frame(width: 300, height: 150)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
            .frame(height: 200)
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
        .safeAreaPadding(.horizontal, 40)
    }
}
