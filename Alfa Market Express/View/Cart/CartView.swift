//
//  CartView.swift
//  WareHouse1
//
//  Created by Said Tapaev on 06.07.2024.
//
import SwiftUI

struct CartView: View {
    @ObservedObject var viewModel: ProductViewModel
    @ObservedObject var profileViewModel: ProfileViewModel
    @State private var searchText = ""
    private let customGreen = Color(red: 38 / 255, green: 115 / 255, blue: 21 / 255)

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                
                HeaderView(viewModel: viewModel, profileViewModel: profileViewModel, customGreen: customGreen)
                    .padding(.top, 0)
                
             
                SearchBar(searchText: $searchText, customGreen: customGreen, viewModel: viewModel)
                    .padding(.vertical, 0)
                    .padding(.horizontal, 0)
                
                List {
                    ForEach(viewModel.cart.filter { $0.name.contains(searchText) }) { product in
                        ProductRowView(product: product, viewModel: viewModel, onFavoriteToggle: {
                            
                        })
                            .swipeActions {
                                Button(role: .destructive) {
                                    viewModel.removeFromCart(product)
                                } label: {
                                    Label("Remove", systemImage: "trash")
                                }
                            }
                    }
                }
               
                
                Text("Общая сумма: \(viewModel.totalPrice)")
                    .font(.headline)
                    .padding()
                
                Button(action: {
                    
                }) {
                    Text("Оформить заказ")
                        .font(.title3)
                        
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(customGreen)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
        }
    }
}

struct CartView_Previews: PreviewProvider {
    static var previews: some View {
        CartView(viewModel: ProductViewModel(), profileViewModel: ProfileViewModel())
    }
}
