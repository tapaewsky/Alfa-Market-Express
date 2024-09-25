//
//  SplashScreen.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 25.09.2024.
//
import SwiftUI

struct SplashScreen: View {
    @State private var isActive = false
    @State private var imageScale: CGFloat = 0.5
    @State private var imageOpacity: Double = 0.0

    var body: some View {
        ZStack {
            Color.colorGreen
                .edgesIgnoringSafeArea(.all)
                .opacity(isActive ? 0 : 1)

            if isActive {
                AuthenticatedView()
                    .transition(.opacity)
            } else {
                GeometryReader { geometry in
                    let logoSize: CGFloat = 250
                    Image("whiteLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: logoSize, height: logoSize)
                        .scaleEffect(imageScale)
                        .opacity(imageOpacity)
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2 - 73)
                        .onAppear {
                            withAnimation(.easeIn(duration: 1.0)) {
                                imageScale = 1.0
                                imageOpacity = 1.0
                            }

                          
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                withAnimation(.easeOut(duration: 1.0)) {
                                    imageScale = 300 / 300
                                }

                               
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                    withAnimation {
                                        self.isActive = true
                                    }
                                }
                            }
                        }
                }
            }
        }
    }
}

struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen()
    }
}
