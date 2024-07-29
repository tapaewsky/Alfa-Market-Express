//
//  ContentView.swift
//  WareHouse1
//
//  Created by Said Tapaev on 06.07.2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ProductViewModel()
    
    var body: some View {
        TabView {
          
                HomeView(viewModel: viewModel)
                    
            
            .tabItem {
                Label("", systemImage: "house")
            }
            
            NavigationView {
                CatalogView(viewModel: viewModel)
                   
            }
            .tabItem {
                Label("", systemImage: "list.dash")
            }
            
            NavigationView {
                CartView(viewModel: viewModel)
                    
            }
            .tabItem {
                Label("", systemImage: "cart")
            }
            
            NavigationView {
                ProfileView(viewModel: viewModel)
                   
            }
            .tabItem {
                Label("", systemImage: "person.circle")
            }
        }
        
//        .onAppear {
//            viewModel.fetchProducts()
//            viewModel.fetchCategories()
        }
    }
//}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
