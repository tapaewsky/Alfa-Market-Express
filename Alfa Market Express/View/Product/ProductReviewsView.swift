//
//  ReviewsView.swift
//  WareHouse1
//
//  Created by Said Tapaev on 11.07.2024.
//

//import SwiftUI
//
//struct ReviewsView: View {
//    var product: Product
//
//
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 16) {
//                Text("Отзывы о \(product.name)")
//                    .font(.title)
//                    .padding()
//
//                if product.reviews.isEmpty {
//                    Text("Пока нет отзывов")
//                        .font(.headline)
//                        .padding()
//                } else {
//                    ForEach(product.reviews) { review in
//                        VStack(alignment: .leading, spacing: 8) {
//                            Text("Оценка: \(review.rating) / 5")
//                                .font(.headline)
//                            Text(review.comment)
//                                .font(.body)
//                        }
//                        .padding(.horizontal)
//                    }
//                }
//
//                Spacer()
//            }
//        }
//        .navigationTitle("Отзывы")
//        .navigationBarTitleDisplayMode(.inline)
//    }
//}
//
//
