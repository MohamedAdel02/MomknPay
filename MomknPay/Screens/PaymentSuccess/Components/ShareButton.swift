//
//  ShareButton.swift
//  MomknPay
//
//  Created by Mohamed Adel on 28/09/2026.
//

import SwiftUI

struct ShareButton<Content: View>: View {

    @Environment(\.displayScale) private var displayScale
    @State private var image: Image?

    let title: String
    let previewTitle: String
    let content: Content

    init(_ title: String, previewTitle: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.previewTitle = previewTitle
        self.content = content()
    }

    var body: some View {
        Group {
            if let image {
                ShareLink(item: image, preview: SharePreview(previewTitle, image: image)) {
                    label
                }
            } else {
                label.opacity(0.5)
            }
        }
        .onAppear { render() }
    }

    private var label: some View {
        Label(title, systemImage: "square.and.arrow.up")
            .font(.system(size: 18, weight: .semibold))
            .foregroundStyle(Color.ink)
            .frame(maxWidth: .infinity)
            .frame(height: 58)
            .background(Color.white, in: RoundedRectangle(cornerRadius: 20))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.inkMuted.opacity(0.3)))
    }

    private func render() {
        let renderer = ImageRenderer(content: content)
        renderer.scale = displayScale
        if let uiImage = renderer.uiImage {
            image = Image(uiImage: uiImage)
        }
    }
}
