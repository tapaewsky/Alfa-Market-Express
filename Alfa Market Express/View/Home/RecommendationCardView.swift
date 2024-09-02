//
//  RecommendationCardView.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 25.07.2024.
//

import SwiftUI

struct RecommendationCardView: View {
    let categories: [Category]
    
    var body: some View {
        NavigationView {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack {
                    ForEach(categories) { category in
                        NavigationLink(destination: CategoryProductsView(viewModel: ProductViewModel(), category: category)) {
                            AsyncImage(url: URL(string: category.imageUrl)) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 300, height: 150)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            } placeholder: {
                                ProgressView()
                                    .frame(width: 300, height: 150)
                            }
                        }
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .safeAreaPadding(.horizontal, 40)
        }
    }
}
