//
//  EnvironmentKeys.swift
//  AlfaMarketExpress
//
//  Created by Said Tapaev on 24.12.2024.
//

import SwiftUI

struct IsSelectionModeKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var isSelectionMode: Bool {
        get { self[IsSelectionModeKey.self] }
        set { self[IsSelectionModeKey.self] = newValue }
    }
}
