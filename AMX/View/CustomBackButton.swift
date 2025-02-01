//
//  SplashScreen.swift
//  AlfaMarketExpress
//
//  Created by Said Tapaev on 24.12.2024.
//
import SwiftUI

struct CustomBackButton: View {
    var label: String = "Назад"
    var colorImage: Color = Color("colorGreen")
    var colorText: Color = .black
    var action: (() -> Void)?
    
    var body: some View {
        Button(action: {
            action?()
        }) {
            HStack {
                Image(systemName: "chevron.left")
                    .foregroundColor(colorImage)
                Text(label)
                    .foregroundColor(colorText)
            }
        }
    }
}
