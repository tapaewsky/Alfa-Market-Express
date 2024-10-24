//
//  SuccessfullOrderView.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 11.10.2024.
//

import SwiftUI

struct SuccessfullOrderView: View {
    @State private var showOrders = false
    @StateObject var viewModel: MainViewModel
    @Binding var selectedTab: Int

    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                
                SuccessIcon(size: min(geometry.size.width, 150))
                
                Spacer()
                
                SuccessMessageView()
                
                Spacer()
                
                OrdersButton {
                    showOrders = true
                }
                .background(
                    NavigationLink(destination: OrdersView(viewModel: viewModel), isActive: $showOrders) {
                        EmptyView()
                    }
                )
                
                HomeButton {
                    print("Navigating to Home")
                    selectedTab = 0
                }
                
                Spacer()
            }
            .navigationBarBackButtonHidden(true)
        }
        .onDisappear {
            print("Resetting order status on disappear") // Message on disappear
            viewModel.cartViewModel.resetOrderStatus()
        }
    }
}

// MARK: - Success Icon

private struct SuccessIcon: View {
    let size: CGFloat

    var body: some View {
        Image(systemName: "checkmark.circle.fill")
            .font(.system(size: size))
            .foregroundColor(.colorGreen)
    }
}

// MARK: - Success Message View

private struct SuccessMessageView: View {
    var body: some View {
        VStack(spacing: 15) {
            Text("Вы успешно сделали заказ!")
                .font(.title2)
                .foregroundColor(.black)
                .bold()
                .multilineTextAlignment(.center)
            Text("Вы можете просмотреть свои заказы.")
                .font(.subheadline)
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal)
    }
}

// MARK: - Orders Button

private struct OrdersButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("Мои заказы")
                .font(.subheadline)
                .foregroundColor(.white)
                .bold()
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.colorGreen)
                .cornerRadius(15)
                .padding(.horizontal)
        }
    }
}

// MARK: - Home Button

private struct HomeButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("Главная")
                .font(.subheadline)
                .foregroundColor(.white)
                .bold()
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.colorGreen)
                .cornerRadius(15)
                .padding(.horizontal)
        }
    }
}

// MARK: - Preview

struct SuccessfullOrderView_Preview: PreviewProvider {
    static var previews: some View {
        SuccessfullOrderView(
            viewModel: MainViewModel(),
            selectedTab: .constant(1)
        )
    }
}
