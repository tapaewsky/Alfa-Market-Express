//
//  AutoScrollingScrollVie.swift
//  Alfa Market Express
//
//  Created by Said Tapaev on 25.07.2024.
//
import SwiftUI
import Combine

struct AutoScrollingScrollView<Content: View>: View {
    let content: () -> Content
       let scrollDirection: Axis.Set
       let scrollInterval: TimeInterval
       let cardCount: Int
    @State private var offset: CGFloat = 0
    @State private var timer: Timer?

    var body: some View {
        GeometryReader { geometry in
            ScrollView(scrollDirection, showsIndicators: false) {
                HStack(spacing: 0) {
                    content()
                        .frame(width: geometry.size.width)
                }
                .offset(x: offset)
                .onAppear {
                    startScrolling(viewWidth: geometry.size.width)
                }
                .onDisappear {
                    stopScrolling()
                }
            }
        }
    }

    private func startScrolling(viewWidth: CGFloat) {
        timer = Timer.scheduledTimer(withTimeInterval: scrollInterval, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 1)) {
                offset -= viewWidth
                if offset < -viewWidth * CGFloat(cardCount - 1) {
                    offset = 0
                }
            }
        }
    }

    private func stopScrolling() {
        timer?.invalidate()
        timer = nil
    }
}
