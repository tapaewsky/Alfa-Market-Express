//
//  CatalogView.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 07.09.2024.
//

import SwiftUI

struct CatalogCardView: View {
    let category: Category

    var body: some View {
        AsyncImage(url: URL(string: category.imageUrl)) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .clipped()
        } placeholder: {
            ProgressView()
        }
    }
}
