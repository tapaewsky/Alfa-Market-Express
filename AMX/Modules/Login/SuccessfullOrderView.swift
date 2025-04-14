//
//  SuccessfullOrderView.swift
//  AlfaMarketExpress
//
//  Created by Said Tapaev on 24.12.2024.
//

import SwiftUI

struct SuccessfullOrderView: View {
    @State private var showOrders = false
    @StateObject var viewModel: MainViewModel
    @Binding var selectedTab: Int
    @State private var showCart = false

    var body: some View {
        GeometryReader { geometry in
            VStack {
                HStack {
                    cartButton(action: {
                        showCart = true
                        print("Navigating to CartView")
                    })
                    .background(
                        NavigationLink(destination: CartView(viewModel: viewModel), isActive: $showCart) {
                            EmptyView()
                        }
                        .navigationBarHidden(true)
                    )
                    .padding()

                    Spacer()
                }

                Spacer()
                SuccessIcon(size: min(geometry.size.width, 150))
                Spacer()
                SuccessMessageView()
                Spacer()

                OrdersButton {
                    showOrders = true
//                    viewModel.ordersViewModel!.fetchOrders(completion: { _ in})
                }
                .background(
                    NavigationLink(destination: OrdersView(viewModel: viewModel),
//                            .onAppear {
//                                viewModel.ordersViewModel!.fetchOrders(completion: { _ in})
//                            },
                                   isActive: $showOrders)
                    {
                        EmptyView()
                    }
                )

                HomeButton {
                    NotificationCenter.default.post(name: Notification.Name("SwitchToHome"), object: nil)
                }

                Spacer()
            }
        }
    }

    private func cartButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: "chevron.left")
                    .foregroundColor(Color("colorGreen"))
                Text("Вернуться в корзину")
                    .font(.subheadline)
                    .foregroundColor(Color("colorGreen"))
            }
        }
    }
}

private struct SuccessIcon: View {
    let size: CGFloat

    var body: some View {
        Image(systemName: "checkmark.circle.fill")
            .font(.system(size: size))
            .foregroundColor(Color("colorGreen"))
    }
}

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
                .background(Color("colorGreen"))
                .cornerRadius(15)
                .padding(.horizontal)
        }
    }
}

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
                .background(Color("colorGreen"))
                .cornerRadius(15)
                .padding(.horizontal)
        }
    }
}

struct SuccessfullOrderView_Preview: PreviewProvider {
    static var previews: some View {
        SuccessfullOrderView(viewModel: MainViewModel(),
                             selectedTab: .constant(1))
    }
}
