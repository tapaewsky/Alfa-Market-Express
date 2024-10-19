//
//  CartView.swift
//  WareHouse1
//
//  Created by Said Tapaev on 06.07.2024.
//
import SwiftUI

struct CartView: View {
    @ObservedObject var viewModel: MainViewModel

    var body: some View {
            CartMainView(viewModel: viewModel)
//                .environmentObject(viewModel)
    }
}

struct CartView_Previews: PreviewProvider {
    static var previews: some View {
        CartView(viewModel: MainViewModel())
    }
}
