//
//  ProfileView.swift
//  WareHouse1
//
//  Created by Said Tapaev on 06.07.2024.
//
import SwiftUI

struct ProfileView: View {
    @State private var selectedTab: Int = 0
    @ObservedObject var viewModel: MainViewModel

    var body: some View {
        VStack(alignment: .leading) {
     
            HStack {
                Spacer()
                NavigationLink(destination: EditProfile(viewModel: viewModel)) {
                    ZStack {
                        Image(systemName: "person")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.colorGreen)

                        Image(systemName: "gearshape")
                            .resizable()
                            .frame(width: 10, height: 10)
                            .foregroundColor(.colorGreen)
                            .offset(x: 15, y: -5)
                    }
                }
                .padding(.horizontal)
            }
            ProfileInfo(viewModel: viewModel)
        }
        .padding()
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(viewModel: MainViewModel())
    }
}
