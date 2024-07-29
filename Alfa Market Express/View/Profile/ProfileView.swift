//
//  ProfileView.swift
//  WareHouse1
//
//  Created by Said Tapaev on 06.07.2024.
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject var viewModel: ProductViewModel
    
    var body: some View {
        VStack {
            Text("Профиль")
                .font(.largeTitle)
                .padding()
           
        }
        .navigationTitle("Профиль")
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(viewModel: ProductViewModel())
    }
}

