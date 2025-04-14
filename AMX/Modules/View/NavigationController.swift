//
//  NavigationController.swift
//  AlfaMarketExpress
//
//  Created by Said Tapaev on 24.12.2024.
//

import SwiftUI
import UIKit

// Обертка для UIKit NavigationController
struct NavigationControllerWrapper<Content: View>: UIViewControllerRepresentable {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    func makeUIViewController(context _: Context) -> UINavigationController {
        let hostingController = UIHostingController(rootView: content)
        let navigationController = UINavigationController(rootViewController: hostingController)

        // Настройка NavigationBar
        navigationController.navigationBar.isHidden = true
        return navigationController
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context _: Context) {
        // Обновляем UI, если нужно
        if let hostingController = uiViewController.viewControllers.first as? UIHostingController<Content> {
            hostingController.rootView = content
        }
    }
}
