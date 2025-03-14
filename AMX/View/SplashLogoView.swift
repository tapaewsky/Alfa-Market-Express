//
//  SplashLogoView.swift
//  AMX
//
//  Created by Said Tapaev on 13.01.2025.
//

import SwiftUI

struct SplashLogoView: View {
    @StateObject private var networkMonitor = NetworkMonitor()
    @State private var isBlinking = false
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                let logoSize: CGFloat = 250
                VStack {
                    Image("splashLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: logoSize, height: logoSize)
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2 - 110)
                    
                    if !networkMonitor.isConnected {
                        Text("Пожалуйста, проверьте своё интернет-соединение и повторите попытку.")
                            .foregroundColor(.red)
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .padding()
                            .opacity(isBlinking ? 0 : 1)
                            .animation(.easeInOut(duration: 0.8).repeatForever(), value: isBlinking)
                            .onAppear {
                                isBlinking.toggle()
                            }
                    }
                }
            }
        }
    }
}
