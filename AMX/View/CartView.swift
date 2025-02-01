//
//  CartView.swift
//  AlfaMarketExpress
//
//  Created by Said Tapaev on 24.12.2024.
//

import SwiftUI

struct CartView: View {
    @ObservedObject var viewModel: MainViewModel
    @StateObject var networkMonitor: NetworkMonitor = NetworkMonitor()

    var body: some View {
        VStack {
            if networkMonitor.isConnected {
                CartMainView(viewModel: viewModel)
                    .navigationBarBackButtonHidden(true)
            } else {
                NoInternetView(viewModel: viewModel)
                    .padding()
            }
        }
    }
}

struct CartView_Previews: PreviewProvider {
    static var previews: some View {
        CartView(viewModel: MainViewModel())
    }
}
