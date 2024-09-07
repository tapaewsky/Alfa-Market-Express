//
//  CategoryGridView.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 07.09.2024.
//
import SwiftUI

struct CatalogGridView: View {
    @ObservedObject var viewModel: ProductViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) { // Убедитесь, что spacing установлен в 0
           
            HStack {
                
                Text("Каталог")
                    .font(.title3)
                    .bold()
                
                Spacer()
                
                NavigationLink(destination: CategoryView(viewModel: viewModel)) {
                    Text("Посмотреть все")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 15)
            
            GeometryReader { geometry in
                let totalWidth = geometry.size.width
                let cardWidth = (totalWidth - 5 * 15) / 4

                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHGrid(rows: [GridItem(.fixed(cardWidth))], spacing: 15) {
                        ForEach(viewModel.categories.prefix(4)) { category in
                            NavigationLink(destination: CategoryProductsView(viewModel: viewModel, category: category)) {
                                VStack {
                                    Text(category.name)
                                        .font(.caption)
                                        .lineLimit(1)
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(.primary)
                                        .padding(.top, 5)
                                    CatalogCardView(category: category)
                                        .frame(width: cardWidth, height: cardWidth)
                                }
                                .frame(width: cardWidth, height: cardWidth + 30)
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(radius: 1)
                                
                            }
                            
                        }
                    }
                    .padding(.horizontal, 15)
                }
            }
            .frame(height: 160)
        }
        .padding(.top, 0)
    }
}
