//
//  WareHouse1App.swift
//  WareHouse1
//
//  Created by Said Tapaev on 06.07.2024.
//
import SwiftUI

@main
struct AlfaMarketExpress: App {
    
    var body: some Scene {
        WindowGroup {
            AuthenticatedView()
                .preferredColorScheme(.light)
        }
    }
}
