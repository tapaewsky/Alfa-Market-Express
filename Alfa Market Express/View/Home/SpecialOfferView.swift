//
//  SpecialOfferView.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 29.07.2024.
//

import SwiftUI

struct SpecialOfferSection: View {
    @ObservedObject var viewModel: ProductViewModel
    let cardSize: CGFloat

    var body: some View {
        AutoScrollingScrollView(content: {
            ForEach(viewModel.categories) { category in
                NavigationLink(destination: CategoryProductsView(viewModel: viewModel, category: category)) {
                    RecommendationCardView(category: category) { selectedCategory in
                        print("Selected category: \(selectedCategory.name)")
                    }
                    .frame(width: cardSize)
                }
            }
        }, scrollDirection: .horizontal, scrollInterval: 4, cardCount: viewModel.categories.count)
        .frame(height: cardSize)
    }
}
