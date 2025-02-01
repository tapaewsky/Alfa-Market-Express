//
//  RegistrationStep1View.swift
//  AMX
//
//  Created by Said Tapaev on 13.01.2025.
//

import SwiftUI

struct RegistrationStep1View: View {
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var address: String = ""
    @State private var profileImage: UIImage? = nil
    @State private var showImagePicker: Bool = false
    
    var onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Шаг 1: Основные данные")
                .font(.title2)
                .bold()
            
            Button(action: {
                showImagePicker.toggle()
            }) {
                if let image = profileImage {
                    Image(uiImage: image)
                        .resizable()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                } else {
                    Image(systemName: "person.crop.circle.badge.plus")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.gray)
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(selectedImage: $profileImage)
            }
            
            CustomTextFieldRegistration(placeholder: "Имя", text: $firstName)
            CustomTextFieldRegistration(placeholder: "Фамилия", text: $lastName)
            CustomTextFieldRegistration(placeholder: "Адрес", text: $address)
            
            Spacer()
            
            CustomButtonRegistration(title: "Продолжить", action: onNext)
        }
        .padding()
    }
}

struct RegistrationStep1View_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationStep1View(onNext: { })
    }
}
