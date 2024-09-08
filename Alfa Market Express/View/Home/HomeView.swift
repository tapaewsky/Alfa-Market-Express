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
    @State private var hasLoadedData: Bool = false

    var body: some View {
        NavigationView {
            VStack {
                Group {
                        HeaderView()
                        ScrollView {
                        RecommendationCardView(categories: viewModel.categories)
                        SearchBar()
                            .padding(.horizontal)
                        
                        if viewModel.isLoading {
                            ProgressView()
                        } else if viewModel.isError {
                            Text("Не удалось загрузить данные. Пожалуйста, проверьте подключение к сети и повторите попытку.")
                                .foregroundColor(.red)
                        } else {
                            VStack {
                                CatalogGridView(viewModel: viewModel)
                                ProductGridView(viewModel: viewModel, onFavoriteToggle: {})
                            }
                        }
                    }
                    
                }
            }
            .onAppear {
               
                if !hasLoadedData {
                    loadData()
                }
            }
            .onChange(of: networkMonitor.isConnected) { isConnected in
                if isConnected && !hasLoadedData {
                    Task {
                        await fetchData()
                    }
                }
            }
        }
    }

    private func loadData() {
        if networkMonitor.isConnected {
            Task {
                await fetchData()
            }
        } else {
           
            viewModel.isError = true
        }
    }

    private func fetchData() async {
        viewModel.isLoading = true
        await viewModel.fetchData { success in
            viewModel.isLoading = false
            hasLoadedData = true
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
