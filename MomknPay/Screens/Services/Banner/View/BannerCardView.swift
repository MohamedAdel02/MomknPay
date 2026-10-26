//
//  BannerCardView.swift
//  MomknPay
//
//  Created by Mohamed Adel on 20/10/2026.
//

import SwiftUI
import Kingfisher

struct BannerCardView: View {

    let banner: Banner
    let cornerRadius: CGFloat

    var body: some View {
        Color.gray.opacity(0.15)
            .overlay {
                if let name = banner.localImageName {
                    Image(name)
                        .resizable()
                        .scaledToFit()
                } else {
                    KFImage(banner.imageURL)
                        .placeholder { ProgressView() }
                        .onFailureView { failureView }
                        .fade(duration: 0.25)
                        .resizable()
                        .scaledToFit()
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }

    private var failureView: some View {
        Image(systemName: "photo")
            .font(.largeTitle)
            .foregroundStyle(Color.gray.opacity(0.5))
    }
}
