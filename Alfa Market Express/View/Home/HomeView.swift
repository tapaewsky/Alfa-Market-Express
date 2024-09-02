//
//  HomeView.swift
//  WareHouse1
//
//  Created by Said Tapaev on 06.07.2024.
//
import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: ProductViewModel

    @StateObject private var networkMonitor = NetworkMonitor()
    @State private var searchText = ""

    private let cardSize: CGFloat = 200
    private let customGreen = Color(red: 38 / 255, green: 115 / 255, blue: 21 / 255)

    var body: some View {
        NavigationView {
            VStack {
                
                Group {
                    HeaderView()
                    SearchBar()
                        .padding(.horizontal)
                    
                    if viewModel.isLoading {
                        ProgressView()
                    } else if viewModel.isError {
                        Text("Не удалось загрузить данные. Пожалуйста, проверьте подключение к сети и повторите попытку.")
                            .foregroundColor(.red)
                    } else {
                        ScrollView {
                            VStack(spacing: 0) {
                                RecommendationCardView(categories: viewModel.categories)
                                ProductGridView(viewModel: viewModel, onFavoriteToggle: {})
                            }
                            .padding(.top, 0)
                        }
                    }
                    Spacer(minLength: 0)
                }
            }
            .environmentObject(viewModel)
            .onAppear {
                if networkMonitor.isConnected {
                    Task {
                        await fetchData()
                    }
                }
            }
            .onChange(of: networkMonitor.isConnected) { isConnected in
                if isConnected {
                    Task {
                        await fetchData()
                    }
                }
            }
        }
    }
    private func fetchData() async {
        viewModel.isLoading = true
        await viewModel.fetchData { success in
            viewModel.isLoading = false
            if !success {
                viewModel.isError = true
            } else {
                viewModel.isError = false
            }
        }
    }
}
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(viewModel: ProductViewModel())
    }
}
