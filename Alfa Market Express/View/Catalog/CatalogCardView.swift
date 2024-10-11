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
        ZStack(alignment: .top) {
            KFImage(URL(string: category.imageUrl ?? "https://example.com/placeholder.png"))
                .placeholder {
                    ProgressView()
                }
                .resizable()
                .scaledToFill()
            Text(category.name)
                .font(.caption)
                .foregroundStyle(.black)
                
        }
        .padding(0)
       
    }
}
