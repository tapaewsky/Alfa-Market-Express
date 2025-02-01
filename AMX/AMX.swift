//
//  AlfaMarketExpressApp.swift
//  AlfaMarketExpress
//
//  Created by Said Tapaev on 24.12.2024.
//

import SwiftUI

@main
struct AMX: App {
    
    var body: some Scene {
        WindowGroup {
            AuthenticatedView()
                .preferredColorScheme(.light)
        }
    }
}

