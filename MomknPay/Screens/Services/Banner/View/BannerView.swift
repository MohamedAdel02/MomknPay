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
   
    private let cardSpacing: CGFloat = 10
    private let cardHeight: CGFloat = 160
    private let cornerRadius: CGFloat = 28
    private let sideMargin: CGFloat = 32
    private let sideScale: CGFloat = 0.8
 
    init(viewModel: BannerViewModel = BannerViewModel()) {
        _viewModel = State(initialValue: viewModel)
        
        
    }
 
    var body: some View {
        if viewModel.isEmpty {
            EmptyView()
        } else {
            VStack(spacing: 12) {
                carousel
                pageIndicator
            }
            .padding(.vertical, 8)
            .environment(\.layoutDirection, .rightToLeft)
        }
        
    }
  
    private var carousel: some View {
        GeometryReader { proxy in
            let cardWidth = proxy.size.width - sideMargin * 2
 
            ScrollView(.horizontal) {
                LazyHStack(spacing: cardSpacing) {
                    ForEach(0..<viewModel.total, id: \.self) { index in
                        BannerCardView(url: viewModel.banner(at: index).imageURL, cornerRadius: cornerRadius)
                            .frame(width: cardWidth, height: cardHeight)
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
 
    private func card(_ banner: Banner) -> some View {
        Color.gray.opacity(0.15)
            .overlay {
                KFImage(banner.imageURL)
                    .placeholder { ProgressView() }
                    .fade(duration: 0.25)
                    .cancelOnDisappear(true)
                    .resizable()
                    .scaledToFill()
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
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
    BannerView()
        .padding(.horizontal, 20)
}
