//
//  RoundedCorners.swift
//  AMX
//
//  Created by Said Tapaev on 03.02.2025.
//

import SwiftUI

// Пользовательский модификатор для округления углов
struct RoundedCorners: ViewModifier {
    var radius: CGFloat
    var corners: UIRectCorner

    func body(content: Content) -> some View {
        content
            .clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

// Структура для округления определенных углов
struct RoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

// Расширение для использования модификатора
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        self.modifier(RoundedCorners(radius: radius, corners: corners))
    }
}
