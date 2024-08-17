//
//  HeaderView.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 29.07.2024.
//

import SwiftUI

struct HeaderView: View {
    @ObservedObject var viewModel: ProductViewModel
    @ObservedObject var profileViewModel: ProfileViewModel
    let customGreen: Color

    var body: some View {
        HStack {
            Image("logo_v1")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 50)

            Spacer()

            
        }
        .padding(5)
        .background(customGreen)
    }
}

struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        HeaderView(
            viewModel: ProductViewModel(),
            profileViewModel: ProfileViewModel(),
            customGreen: Color(red: 38 / 255, green: 115 / 255, blue: 21 / 255)
        )
    }
}
