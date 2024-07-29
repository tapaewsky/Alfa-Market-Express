//
//  CartView.swift
//  WareHouse1
//
//  Created by Said Tapaev on 06.07.2024.
//
import SwiftUI

import SwiftUI

struct CartView: View {
    @ObservedObject var viewModel: ProductViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                List(viewModel.cart) { product in
                    CartItemView(product: product) {
                        
                        viewModel.removeFromCart(product)
                    }
                }
                .navigationTitle("Корзина")
                
               
                Text("Общая сумма: \(viewModel.totalPrice) ₽")
                    .font(.headline)
                    .padding()
                
               
                Button(action: {
                    
                }) {
                    Text("Оплатить")
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
        }
    }
}

struct CartItemView: View {
    var product: Product
    var onRemove: () -> Void
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: product.imageUrl)) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
            } placeholder: {
                ProgressView()
                    .frame(width: 50, height: 50)
            }
            Text(product.name)
            Spacer()
            Text("\(product.price) ₽")
            Button(action: {
               
                onRemove()
            }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

struct CartView_Previews: PreviewProvider {
    static var previews: some View {
        CartView(viewModel: ProductViewModel())
    }
}
