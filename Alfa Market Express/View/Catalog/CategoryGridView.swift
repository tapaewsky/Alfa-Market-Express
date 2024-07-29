//
//  CategoriesGridView.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 29.07.2024.
//

import SwiftUI

struct CategoryGridView: View {
    
    
    @ObservedObject var viewModel = ProductViewModel()
    
    
    var body: some View {
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 5) {
                ForEach(viewModel.categories) { category in
                    NavigationLink(destination: CategoryProductsView(viewModel: viewModel, category: category)) {
                        CategoryCardView(category: category)
                        
//                            .padding(5)
                        
                    }
                }
            }
            
        }
    }
    

    


