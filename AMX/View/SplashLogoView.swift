//
//  SplashLogoView.swift
//  AMX
//
//  Created by Said Tapaev on 13.01.2025.
//

import SwiftUI

struct SplashLogoView: View {
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                let logoSize: CGFloat = 250
                Image("splashLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: logoSize, height: logoSize)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2 - 110)
            }
        }
    }
}
