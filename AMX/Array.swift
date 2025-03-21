//
//  Array.swift
//  AMX
//
//  Created by Said Tapaev on 21.03.2025.
//

import SwiftUI

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)]) 
        }
    }
}
