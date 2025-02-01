//
//  RegistrationView.swift
//  AMX
//
//  Created by Said Tapaev on 13.01.2025.
//

import SwiftUI

struct RegistrationView: View {
    @State private var currentStep: RegistrationStep = .step1
    
    var body: some View {
        VStack {
            switch currentStep {
            case .step1:
                RegistrationStep1View(onNext: {
                    currentStep = .step2
                })
            case .step2:
                RegistrationStep2View(onNext: {
                    currentStep = .step3
                })
            case .step3:
                RegistrationStep3View(onNext: {
                    currentStep = .step4
                })
            case .step4:
                RegistrationStep4View(onComplete: {
                    print("Регистрация завершена")
                })
            }
        }
        .animation(.easeInOut, value: currentStep)
    }
}

enum RegistrationStep {
    case step1, step2, step3, step4
}

struct RegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationView()
    }
}
