//
//  ProductRowView.swift
//  WareHouse1
//
//  Created by Said Tapaev on 06.07.2024.
//

import SwiftUI

struct ProductRowView: View {
    var product: Product

    var body: some View {
        HStack {
            AsyncImage(url: URL(string: product.imageUrl)) { image in
                image.resizable()
                    .frame(width: 50, height: 50)
                    .aspectRatio(contentMode: .fill)
                    .clipped()
            } placeholder: {
                ProgressView()
            }
            VStack(alignment: .leading) {
                Text(product.name)
                    .font(.headline)
                Text(String(format: "%.0f ₽", Double(product.price) ?? 0))
                    .font(.subheadline)
            }
            Spacer()
        }
        .padding()
    }
}

