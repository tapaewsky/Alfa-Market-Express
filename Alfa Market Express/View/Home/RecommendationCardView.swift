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
    @State var isFetching: Bool = false
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                ForEach(viewModel.slideViewModel.slides, id: \.id) { singleSlide in
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
                        Color.gray
                            .frame(width: 305, height: 150)
                            .cornerRadius(10)
                            .overlay(Text("Invalid URL").foregroundColor(.white))
                    }
                }
            }
            .frame(height: 200)
            .scrollTargetLayout()
        }
        .onAppear() {
            loadSlides()
        }

        .scrollTargetBehavior(.viewAligned)
        .padding(.horizontal, 35)
    }
    private func loadSlides() {
        isFetching = true
        viewModel.slideViewModel.fetchSlides { success in
            DispatchQueue.main.async {
                isFetching = false
                if success {
                    print("Избранное успешно загружена")
                } else {
                    print("Не удалось загрузить избранное")
                }
            }
        }
    }
}
