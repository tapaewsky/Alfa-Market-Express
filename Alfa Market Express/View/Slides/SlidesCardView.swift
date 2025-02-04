//
//  RecommendationCardView.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 25.07.2024.
//
import SwiftUI
import Kingfisher

struct SlidesCardView: View {
    @StateObject var viewModel: MainViewModel
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                ForEach(viewModel.slideViewModel.slides, id: \.id) { singleSlide in
                    Button(action: {
                        let slideDetailView = SlidesView(slide: singleSlide)
                        let hostingController = UIHostingController(rootView: slideDetailView)
                        UIApplication.shared.windows.first?.rootViewController?.present(hostingController, animated: true)
                    }) {
                        if let imageUrl = URL(string: singleSlide.image) {
                            KFImage(imageUrl)
                                .placeholder {
                                    Image("placeholderSlide")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 300, height: 150)
                                        .cornerRadius(10)
                                }
                                .resizable()
                                .scaledToFill()
                                .frame(width: 300, height: 150)
                                .cornerRadius(10)
                        } else {
                            Image("placeholderSlide")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 300, height: 150)
                                .cornerRadius(10)
                        }
                    }
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
        .safeAreaPadding(.horizontal, 50)
    }
}
