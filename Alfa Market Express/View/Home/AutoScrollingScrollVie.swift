//
//  AutoScrollingScrollVie.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 25.07.2024.
//
//import SwiftUI
//
//struct AutoScrollingScrollView<Content: View>: View {
//    let content: () -> Content
//    let scrollDirection: Axis.Set
//    let scrollInterval: TimeInterval
//    let cardCount: Int
//    @State private var offset: CGFloat = 0
//    @State private var timer: Timer?
//    private let animationDuration: TimeInterval = 1
//
//    var body: some View {
//        GeometryReader { geometry in
//            ScrollView(scrollDirection, showsIndicators: false) {
//                ScrollViewReader { proxy in
//                    LazyHStack(spacing: 0) {
//                        ForEach(0..<cardCount, id: \.self) { _ in
//                            content()
//                                .frame(width: geometry.size.width)
//                        }
//                    }
//                    .onChange(of: offset) { newValue in
//                        withAnimation(.linear(duration: animationDuration)) {
//                            proxy.scrollTo(Int(offset / geometry.size.width), anchor: .center)
//                        }
//                    }
//                    .onAppear {
//                        startAutoScrolling(geometry: geometry)
//                    }
//                    .onDisappear {
//                        timer?.invalidate()
//                    }
//                }
//            }
//            .scrollTargetBehavior(.viewAligned)
//            
//        }
//    }
//    
//    private func startAutoScrolling(geometry: GeometryProxy) {
//        let scrollWidth = geometry.size.width
//        let totalWidth = scrollWidth * CGFloat(cardCount)
//        
//        timer = Timer.scheduledTimer(withTimeInterval: scrollInterval, repeats: true) { _ in
//            withAnimation(.linear(duration: animationDuration)) {
//                if offset >= totalWidth - scrollWidth {
//                    offset = 0
//                } else {
//                    offset += scrollWidth
//                }
//            }
//        }
//    }
//}

