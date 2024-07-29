//
//  UtilityTypes.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 13.08.2024.
//

import Foundation
import SwiftUI


enum Errors {
    static func messageFor(err: String) -> String {
        return err
    }
}


struct IdentifiableAlert: Identifiable {
    let id: String
    let message: String
    
    static func buildForError(id: String, message: String) -> IdentifiableAlert {
        return IdentifiableAlert(id: id, message: message)
    }
    
    static func networkError() -> IdentifiableAlert {
        return IdentifiableAlert(id: "network_error", message: "A network error occurred.")
    }
}


enum LoadingState {
    case notStarted
    case loading
    case finished
    case error
}
