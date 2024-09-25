//
//  SplashScreen 2.swift
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
                .opacity(isActive ? 0 : 1) // Фон пропадает вместе с анимацией

            if isActive {
                LoginView() // Переход к LoginView
                    .transition(.opacity) // Добавляем плавный переход
            } else {
                GeometryReader { geometry in
                    let logoSize: CGFloat = 250 // Размер логотипа
                    let logoBottomPadding: CGFloat = 40 // Отступ снизу, такой же как у blackLogo

                    Image("whiteLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: logoSize, height: logoSize) // Устанавливаем фиксированный размер
                        .scaleEffect(imageScale)
                        .opacity(imageOpacity)
                        .position(x: geometry.size.width / 2, y: (geometry.size.height / 2) - (logoSize / 2) - logoBottomPadding) // Центрируем по экрану с отступом
                        .onAppear {
                            // Начальная анимация увеличения изображения
                            withAnimation(.easeIn(duration: 1.0)) {
                                imageScale = 1.0
                                imageOpacity = 1.0
                            }

                            // Анимация уменьшения после задержки
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                withAnimation(.easeOut(duration: 1.0)) {
                                    imageScale = logoSize / 300 // Уменьшаем до 250x250
                                }

                                // Переход к следующему представлению
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