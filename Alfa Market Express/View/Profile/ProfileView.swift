//
//  ProfileView.swift
//  WareHouse1
//
//  Created by Said Tapaev on 06.07.2024.
//
import SwiftUI

struct ProfileView: View {
    @ObservedObject var viewModel: MainViewModel
    
    var body: some View {
        VStack {
            ProfileInfo(viewModel: ProfileViewModel())
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(viewModel: MainViewModel())
    }
}
