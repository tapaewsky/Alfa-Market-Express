//
//  NoInternetView.swift
//  AlfaMarketExpress
//
//  Created by Said Tapaev on 24.12.2024.
//

import SwiftUI

struct NoInternetView: View {
    @StateObject var viewModel = MainViewModel()

    var body: some View {
        VStack {
            Image("NoWi-fi")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .clipShape(Circle())

            Text("Нет соединения")
                .font(.headline)
                .bold()
                .multilineTextAlignment(.center)

            Text("Проверьте соединение с сетью!")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .padding(.bottom, 20)

//            Button(action: {
//                viewModel.productViewModel.resetData()
//                print("Обновить нажато")
//            }) {
//                Text("Обновить")
//                    .font(.headline)
//                    .bold()
//                    .foregroundColor(.white)
//                    .padding()
//                    .background(.colorRed.opacity(0.8))
//                    .cornerRadius(20)
//            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct NoInternetView_Previews: PreviewProvider {
    static var previews: some View {
        NoInternetView(viewModel: MainViewModel())
    }
}
