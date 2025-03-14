//
//  SlidesView.swift
//  AlfaMarketExpress
//
//  Created by Said Tapaev on 24.12.2024.
//

import SwiftUI
import Kingfisher

struct SlidesView: View {
    var slide: Slide
    
    var body: some View {
        VStack(alignment: .center) {
            KFImage(URL(string: slide.image))
                .placeholder {
                    Image("placeholderSlide")
                        .resizable()
                        .scaledToFill()
                        .frame(height: 170)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                .resizable()
                .scaledToFill()
                .frame(height: 170)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                
            
            ScrollView {
                Text(slide.title ?? "Нет описания")
                    .font(.body)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.clear)
            }
            .padding(.bottom)
            Spacer()
        }
        .padding()
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SlidesView_Preview: PreviewProvider {
    static var previews: some View {
        let slide = Slide(id: 1, title: "Slide Title", image: "https://avatars.mds.yandex.net/i?id=28a5674b17cbd5e178f4eb0c81dc642308cb1e81-13469218-images-thumbs&n=13", link: "http://example.com", description: "This is the description for the slide. It can be quite long and should scroll if it's too long to fit on the screen.")
        SlidesView(slide: slide)
    }
}
