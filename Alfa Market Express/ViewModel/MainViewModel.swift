//
//  MainViewModel.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 12.08.2024.
//

import SwiftUI
import Combine

import Network
import Models

class MainViewModel: ObservableObject {

    @Published var showAuthContainer = true
    @Published var loginPending = false
    @Published var registerPending = false
    @Published var devsProgress: LoadingState = .notStarted
    @Published var developers: [Developer] = []
    @Published var alert: IdentifiableAlert?

    init() {
        let refreshToken = UserDefaultsWorker.shared.getRefreshToken()
        if !refreshToken.token.isEmpty && refreshToken.expiresAt > Date().timestampMillis() {
            showAuthContainer = false
        }
    }
    

    func logout() {
        UserDefaultsWorker.shared.dropTokens()
        Requester.shared.dropTokens()
        withAnimation {
            showAuthContainer = true
        }
    }

    func login(login: String, password: String) {
        withAnimation {
            loginPending = true
        }
        DispatchQueue.global(qos: .userInitiated).async {
            Requester.shared.login(authBody: AuthBody(login: login, password: password)) { [self] result in
                withAnimation {
                    loginPending = false
                }
                switch result {
                case .success(let user):
                    
                    withAnimation {
                        self.showAuthContainer = false
                    }
                case .serverError(let err):
                    alert = IdentifiableAlert.buildForError(id: "login_server_err", message: Errors.messageFor(err: err.message))
                case .networkError(_):
                    alert = IdentifiableAlert.networkError()
                case .authError(let err):
                    alert = IdentifiableAlert.buildForError(id: "login_err", message: Errors.messageFor(err: err.message))
                }
            }
        }
    }

    func register(login: String, password: String) {
       
    }

    func getDevelopers() {
        withAnimation {
            devsProgress = .loading
        }
        DispatchQueue.global(qos: .userInitiated).async {
            Requester.shared.getDevelopers() { [self] result in
                withAnimation {
                    registerPending = false
                }
                switch result {
                case .success(let devs):
                    withAnimation {
                        developers = devs
                        devsProgress = .finished
                    }
                case .serverError(let err):
                    withAnimation {
                        devsProgress = .error
                    }
                    alert = IdentifiableAlert.buildForError(id: "devs_server_err", message: Errors.messageFor(err: err.message))
                case .networkError(_):
                    withAnimation {
                        devsProgress = .error
                    }
                    alert = IdentifiableAlert.networkError()
                case .authError(let err):
                    withAnimation {
                        self.showAuthContainer = true
                    }
                }
            }
        }
    }
}
