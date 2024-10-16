//
//  customBackButton.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 17.10.2024.
//

import SwiftUI

struct CustomBackButton: View {
    var label: String = "Назад"  // По умолчанию текст "Назад", можно менять
    var color: Color = .blue     // По умолчанию синий цвет, можно менять
    var action: () -> Void       // Действие при нажатии на кнопку
    
    var body: some View {
        Button(action: {
            action()  // Выполняем переданное действие
        }) {
            HStack {
                Image(systemName: "chevron.left")
                    .foregroundColor(color) // Цвет иконки
                Text(label)
                    .foregroundColor(color) // Цвет текста
            }
        }
    }
}
