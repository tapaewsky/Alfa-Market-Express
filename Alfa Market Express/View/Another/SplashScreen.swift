//
//  SplashScreen.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 25.09.2024.
//
//import SwiftUI
//
//struct SplashScreen: View {
//    @State private var isActive = false
//
//    var body: some View {
//        ZStack {
//            Color.colorGreen
//                .edgesIgnoringSafeArea(.all)
//
//            if isActive {
//                AuthenticatedView()
//                    .transition(.opacity)
//            } else {
//                GeometryReader { geometry in
//                    let logoSize: CGFloat = 250
//                    Image("whiteLogo")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: logoSize, height: logoSize)
//                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2 - 110)
//                        .onAppear {
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { // Уменьшили время до 1 секунды
//                                self.isActive = true
//                            }
//                        }
//                }
//            }
//        }
//    }
//}
//
//struct SplashScreen_Previews: PreviewProvider {
//    static var previews: some View {
//        SplashScreen()
//    }
//}
