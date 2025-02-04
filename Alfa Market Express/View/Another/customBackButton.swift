//
//  customBackButton.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 17.10.2024.
//

import SwiftUI

struct CustomBackButton: View {
    var label: String = "Назад"
    var colorImage: Color = .colorGreen
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
