//
//  BannersView.swift
//  MomknPay
//
//  Created by Mohamed Adel on 20/10/2026.
//

import SwiftUI
import Kingfisher

struct BannerView: View {

    @State var viewModel: BannerViewModel
    @State private var cardHeight: CGFloat = 160
    @Environment(\.openURL) private var openURL

    private let imageRatio: CGFloat = 16.0 / 9.0
    private let cardSpacing: CGFloat = 10
    private let cornerRadius: CGFloat = 28
    private let sideMargin: CGFloat = 32
    private let sideScale: CGFloat = 0.8

    var body: some View {
        VStack(spacing: 12) {
            carousel
            pageIndicator
        }
        .padding(.vertical, 8)
        .environment(\.layoutDirection, .rightToLeft)
        .task { await viewModel.load() }
    }

    private var carousel: some View {
        GeometryReader { proxy in
            let cardWidth = proxy.size.width - sideMargin * 2

            ScrollView(.horizontal) {
                LazyHStack(spacing: cardSpacing) {
                    ForEach(0..<viewModel.total, id: \.self) { index in
                        BannerCardView(banner: viewModel.banner(at: index), cornerRadius: cornerRadius)
                            .frame(width: cardWidth, height: cardHeight)
                            .onTapGesture {
                                if let link = viewModel.banner(at: index).linkURL { openURL(link) }
                            }
                            .scrollTransition(.interactive, axis: .horizontal) { content, phase in
                                let distance = min(abs(phase.value), 1)
                                return content.scaleEffect(x: 1, y: 1 - (1 - sideScale) * distance)
                            }
                            .id(index)
                    }
                }
                .scrollTargetLayout()
            }
            .contentMargins(.horizontal, sideMargin, for: .scrollContent)
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $viewModel.currentID)
            .scrollIndicators(.hidden)
        }
        .frame(height: cardHeight)
        .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { width in
            cardHeight = (width - sideMargin * 2) / imageRatio
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in viewModel.touchBegan() }
                .onEnded { _ in viewModel.touchEnded() }
        )
        .onChange(of: viewModel.currentID) { _, newValue in
            viewModel.positionChanged(newValue)
        }
        .task {
            await viewModel.runAutoScroll(step: 1)
        }
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(viewModel.banners.indices, id: \.self) { page in
                Capsule()
                    .fill(Color.gray.opacity(page == viewModel.currentPage ? 0.35 : 0.25))
                    .frame(width: page == viewModel.currentPage ? 44 : 12, height: 12)
            }
        }
        .animation(.spring(duration: 0.3), value: viewModel.currentPage)
    }
}

#Preview {
    BannerView(viewModel: BannerViewModel())
        .padding(.horizontal, 20)
}
