//
//  CustomTabBarModifier.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 08.09.2024.
//

import SwiftUI
import UIKit

struct CustomTabBarModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(TabBarCustomization())
    }
}

struct TabBarCustomization: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.backgroundColor = .white
        tabBarAppearance.shadowColor = .clear
        tabBarAppearance.backgroundEffect = UIBlurEffect(style: .systemMaterialDark)

        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
        tabBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        
        // Customize the tab bar's rounded corners
        tabBarAppearance.backgroundImage = UIImage()
        tabBarAppearance.shadowImage = UIImage()

        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
