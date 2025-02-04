//
//  HeaderView.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 29.07.2024.
//
import SwiftUI

struct HeaderView<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        HStack {
            content
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .frame(height: 60)
        .background(Color.colorGreen)
    }
}

struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        HeaderView {
            Text("Header Content")
        }
    }
}
