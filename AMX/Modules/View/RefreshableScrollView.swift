//
//  RefreshableScrollView.swift
//  AlfaMarketExpress
//
//  Created by Said Tapaev on 24.12.2024.
//

import SwiftUI

struct RefreshableScrollView<Content: View>: View {
    let refreshAction: () async -> Void
    let content: Content

    init(refreshAction: @escaping () async -> Void, @ViewBuilder content: () -> Content) {
        self.refreshAction = refreshAction
        self.content = content()
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack {
                Spacer()
                    .frame(height: 0)
                    .onAppear {
                        UIRefreshControl.appearance().tintColor = .gray
                    }
                content
            }
        }
        .refreshable {
            await refreshAction()
        }
    }
}
