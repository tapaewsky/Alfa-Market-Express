//
//  URLCache.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 09.08.2024.
//

import SwiftUI

struct CachedAsyncImage: View {
    let url: URL
    @State private var image: UIImage?

    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
            } else {
                ProgressView()
                    .onAppear {
                        loadImage()
                    }
            }
        }
    }

    private func loadImage() {
        let request = URLRequest(url: url)
        if let cachedResponse = URLCache.shared.cachedResponse(for: request),
           let cachedImage = UIImage(data: cachedResponse.data) {
            self.image = cachedImage
        } else {
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let data = data, let response = response, let loadedImage = UIImage(data: data) {
                    let cachedData = CachedURLResponse(response: response, data: data)
                    URLCache.shared.storeCachedResponse(cachedData, for: request)
                    DispatchQueue.main.async {
                        self.image = loadedImage
                    }
                }
            }.resume()
        }
    }
}
