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
        HStack {
            Text(category.name)
                .font(.caption)
                .foregroundStyle(.black)
        }
        KFImage(URL(string: category.imageUrl ?? "https://example.com/placeholder.png"))
            .placeholder {
                ProgressView()
            }
            .resizable()
            .aspectRatio(contentMode: .fill)
            .clipped()
            .frame(width: 50, height: 50)
    }
}
