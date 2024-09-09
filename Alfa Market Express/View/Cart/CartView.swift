//
//  CartView.swift
//  WareHouse1
//
//  Created by Said Tapaev on 06.07.2024.
//
import SwiftUI

struct CartView: View {
    @ObservedObject var viewModel: ProductViewModel
    @ObservedObject var сartViewModel: CartViewModel
    @ObservedObject var favoritesViewModel: FavoritesViewModel
    @State private var searchText = ""
    
    var body: some View {
        VStack {
            Group {
//                HeaderView()
//                SearchBar()
//                    .padding(.horizontal, 16)
                
//                List {
//                    ForEach(сartViewModel.cart.filter { $0.name.contains(searchText) }) { product in
//                        ProductRowView(product: product, viewModel: viewModel, onFavoriteToggle: {
//                        })
//                        .swipeActions {
//                            Button(role: .destructive) {
//                                сartViewModel.removeFromCart(product)
//                            } label: {
//                                Label("Remove", systemImage: "trash")
//                            }
//                        }
//                    }
//                }
//                
                
                Text("Общая сумма: \(сartViewModel.totalPrice, specifier: "%.2f") ₽")
                    .font(.headline)
                    .padding()
                
                Button(action: {
                    
                }) {
                    Text("Оформить заказ")
                        .font(.title3)
                    
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.main)
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
        CartView(viewModel: ProductViewModel(), сartViewModel: CartViewModel(), favoritesViewModel: FavoritesViewModel())
    }
}
