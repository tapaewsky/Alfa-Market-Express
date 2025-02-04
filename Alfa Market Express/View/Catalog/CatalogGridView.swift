//
//  CategoryGridView.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 07.09.2024.
//
//import SwiftUI
//
//struct CatalogGridView: View {
//    @ObservedObject var viewModel: MainViewModel
//    @State private var shuffledCategories: [Category] = []
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 0) {
//            
//            HStack {
//                
//                Text("Каталог")
//                    .font(.title3)
//                    .bold()
//                
//                Spacer()
//                
//                NavigationLink(destination: CategoryView(viewModel: viewModel)) {
//                    Text("Посмотреть все")
//                        .font(.footnote)
//                        .foregroundColor(.gray)
//                }
//            }
//            .padding(.horizontal, 15)
//            Spacer()
//            
//            GeometryReader { geometry in
//                let totalWidth = geometry.size.width
//                let cardWidth = (totalWidth - 5 * 15) / 4
//                
//                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: 4), spacing: 15) {
//                    ForEach(shuffledCategories.prefix(4)) { category in
//                        NavigationLink(destination: CategoryProductsView(viewModel: viewModel, category: category)) {
//                            VStack {
//                                CatalogCardView(category: category)
//                            }
//                            .frame(width: cardWidth, height: cardWidth)
//                            .background(Color.white)
//                            .cornerRadius(10)
//                            .shadow(radius: 1)
//                        }
//                    }
//                }
//                .padding(.horizontal, 15)
//            }
//            .padding(/*.top,*/ 0)
//            .frame(height: 100)
//            .shadow(radius: 2)
//            
//        }
//        .onAppear {
//            shuffleCategories()
//        }
//    }
//    
//    private func shuffleCategories() {
//        shuffledCategories = viewModel.categoryViewModel.categories.shuffled()
//    }
//}
