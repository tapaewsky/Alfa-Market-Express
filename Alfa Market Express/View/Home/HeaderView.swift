//
//  HeaderView.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 29.07.2024.
//

import SwiftUI

struct HeaderView: View {
    var backgroundColor = Color.main

    var body: some View {
        Group {
            Image("logo_v1")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 50)
                .padding(5)
        }
        .frame(height: 60)
        .frame(maxWidth: .infinity)
        .background(backgroundColor)
    }
}

struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        HeaderView()
    }
}
