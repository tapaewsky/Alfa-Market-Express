//
//  HeaderView.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 29.07.2024.
//

import SwiftUI

struct HeaderView: View {
    @ObservedObject var viewModel: ProductViewModel
    let customGreen: Color

    var body: some View {
        HStack {
            Image("logo_v1")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 40)

            Spacer()

            NavigationLink(destination: FavoritesView(viewModel: viewModel)) {
                Image(systemName: "heart")
                    .foregroundColor(.white)
                    .font(.title3)
                    .padding(8)
                    .background(customGreen)
                    .clipShape(Circle())
            }
        }
        .padding(5)
        .background(customGreen)
    }
}
