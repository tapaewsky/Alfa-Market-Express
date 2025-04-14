//
//  RegistrationView.swift
//  AMX
//
//  Created by Said Tapaev on 13.01.2025.
//

import SwiftUI

struct RegistrationView: View {
    @State private var phone: String = ""
    @StateObject private var registrationViewModel = RegistrationVM()

    var body: some View {
        PhoneNumberView(viewModel: registrationViewModel)
    }
}

struct RegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationView()
    }
}
