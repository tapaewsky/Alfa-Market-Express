//
//  CatalogView.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 07.09.2024.
//

import SwiftUI
import Kingfisher

struct CatalogCardView: View {
    let category: Category

    var body: some View {
        KFImage(URL(string: category.imageUrl))
            .placeholder {
                ProgressView()
            }
            .resizable()
            .aspectRatio(contentMode: .fill)
            .clipped()
    }
}
