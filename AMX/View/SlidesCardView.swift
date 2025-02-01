//
//  SlidesCardView.swift
//  AlfaMarketExpress
//
//  Created by Said Tapaev on 24.12.2024.
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
                        if let topController = getTopMostViewController() {
                            topController.present(hostingController, animated: true)
                        }
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
    
 
    private func getTopMostViewController() -> UIViewController? {
        guard let rootViewController = UIApplication.shared.connectedScenes
                .compactMap({ ($0 as? UIWindowScene)?.keyWindow?.rootViewController })
                .first else {
            return nil
        }
        var topController: UIViewController? = rootViewController
        while let presentedController = topController?.presentedViewController {
            topController = presentedController
        }
        return topController
    }
}
