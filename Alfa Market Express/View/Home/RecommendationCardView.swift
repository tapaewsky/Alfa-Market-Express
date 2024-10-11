//
//  RecommendationCardView.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 25.07.2024.
//
import SwiftUI
import Kingfisher

struct RecommendationCardView: View {
    @ObservedObject var viewModel: MainViewModel
    var products: [Product]
    let categories: [Category]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                ForEach(categories) { category in
                    NavigationLink(destination: CategoryProductsView(viewModel: viewModel, category: category)) {
                        KFImage(URL(string: category.imageUrl ?? "https://example.com/placeholder.png"))
                            .placeholder {
                                ProgressView()
                                    .frame(width: 300, height: 150)
                            }
                            .resizable()
                            .scaledToFill()
                            .frame(width: 305, height: 150)
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

