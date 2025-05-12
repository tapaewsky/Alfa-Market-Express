//
//  SlidesCardView.swift
//  AlfaMarketExpress
//
//  Created by Said Tapaev on 24.12.2024.
//

import Kingfisher
import SwiftUI

struct SlidesCardView: View {
    @StateObject var viewModel: MainViewModel

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 3) {
                ForEach(viewModel.slideViewModel.slides, id: \.id) { slide in
                    Button(action: {
                        let slideDetailView = SlidesView(slide: slide)
                        let hostingController = UIHostingController(rootView: slideDetailView)
                        if let topController = getTopMostViewController() {
                            topController.present(hostingController, animated: true)
                        }
                    }) {
                        if let imageUrl = URL(string: slide.image) {
                            ZStack {
                                KFImage(imageUrl)
                                    .placeholder {
                                        Image("placeholderSlide")
                                            .resizable()
                                            .scaledToFill()
                                            .frame(height: 170)
                                            .clipShape(RoundedRectangle(cornerRadius: 20))
                                    }
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 170)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                            }
                            .containerRelativeFrame(.horizontal)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                        }
                    }
                }
            }
            .scrollTargetLayout()
        }
        .contentMargins(15)
        .scrollTargetBehavior(.viewAligned)
    }

    private func getTopMostViewController() -> UIViewController? {
        guard let rootViewController = UIApplication.shared.connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.keyWindow?.rootViewController })
            .first
        else {
            return nil
        }
        var topController: UIViewController? = rootViewController
        while let presentedController = topController?.presentedViewController {
            topController = presentedController
        }
        return topController
    }
}
