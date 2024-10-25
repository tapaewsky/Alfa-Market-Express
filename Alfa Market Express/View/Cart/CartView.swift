//
//  CartView.swift
//  WareHouse1
//
//  Created by Said Tapaev on 06.07.2024.
//
import SwiftUI

struct CartView: View {
    @StateObject var viewModel: MainViewModel
    
    var body: some View {
        CartMainView(viewModel: viewModel)
            .navigationBarBackButtonHidden(true)
    }
        
}

struct CartView_Previews: PreviewProvider {
    static var previews: some View {
        CartView(viewModel: MainViewModel())
    }
}
