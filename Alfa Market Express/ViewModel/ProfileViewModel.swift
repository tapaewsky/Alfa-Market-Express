//
//  ProfileViewModel.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 15.08.2024.
//

import SwiftUI

class ProfileViewModel: ObservableObject {
    @Published var userProfile: UserProfile
    @Published var isEditing: Bool = false
    
    init() {
        self.userProfile = UserProfile(
            username: "",
            firstName: "",
            lastName: "",
            storeName: "",
            storeAddress: "",
            storePhoneNumber: "",
            managerName: "",
            managerPhoneNumber: "",
            storeCode: "",
            outstandingDebt: 0.0,
            profileImageUrl: "https://via.placeholder.com/100"
        )
    }
    
    func toggleEditing() {
        isEditing.toggle()
    }
}
