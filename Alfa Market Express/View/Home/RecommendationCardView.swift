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
    let slide: [Slide]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                ForEach(slide, id: \.id) { singleSlide in
                    if let imageUrl = URL(string: singleSlide.image) {
                        KFImage(imageUrl)
                            .placeholder {
                                ProgressView()
                                    .frame(width: 300, height: 150)
                            }
                            .resizable()
                            .scaledToFill()
                            .frame(width: 305, height: 150)
                            .cornerRadius(10)
                    } else {
                        Text("Invalid URL")
                            .frame(width: 305, height: 150)
                            .background(Color.gray)
                            .cornerRadius(10)
                    }

                }
            }
            .frame(height: 200)
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
        .safeAreaPadding(.horizontal,35)
    }
}
