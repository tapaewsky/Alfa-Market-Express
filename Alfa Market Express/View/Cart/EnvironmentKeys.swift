//
//  EnvironmentKeys.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 24.09.2024.
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
