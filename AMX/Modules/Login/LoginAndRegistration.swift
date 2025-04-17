//
//  LoginAndRegistration.swift
//  AMX
//
//  Created by Said Tapaev on 13.01.2025.
//

import SwiftUI

struct LoginAndRegistration: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Профиль")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            VStack(alignment: .leading, spacing: 8) {
                Text("Войдите в приложение")
                    .font(.headline)
                    .foregroundColor(.black)

                Text("Откройте доступ ко всем функциям приложения.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)

            NavigationLink(destination: PhoneNumberView(viewModel: RegistrationVM())) {
                Text("Войти")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(Color.colorGreen)
                    .cornerRadius(12)
                    .padding(.horizontal)
            }

            Spacer()
            

            HStack(spacing: 4) {
                Text("Created by:")
                    .foregroundColor(.gray)
                Link("tapaewsky", destination: URL(string: "https://t.me/sdtpv")!)
                    .foregroundColor(.blue)
            }
            .font(.footnote)
            .padding(.bottom, 12)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct LoginAndRegistration_Previews: PreviewProvider {
    static var previews: some View {
        LoginAndRegistration()
    }
}
