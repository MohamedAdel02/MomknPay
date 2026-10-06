//
//  ServiceIcon.swift
//  MomknPay
//
//  Created by Mohamed Adel on 05/10/2026.
//

import SwiftUI
import Kingfisher

struct ServiceIcon: View {

    let service: Service

    var body: some View {
        Group {
            if let urlString = service.iconUrl, let url = URL(string: urlString) {
                KFImage(url)
                    .placeholder { placeholderIcon }
                    .fade(duration: 0.2)
                    .cancelOnDisappear(true)
                    .resizable()
                    .scaledToFit()
                    .padding(12)
            } else {
                placeholderIcon
            }
        }
        .frame(width: 56, height: 56)
        .background(
            Color.inkMuted.opacity(0.12),
            in: RoundedRectangle(cornerRadius: 16, style: .continuous)
        )
    }

    private var placeholderIcon: some View {
        Image(systemName: "square.grid.2x2")
            .font(.title2)
            .foregroundStyle(service.available ? Color.ink : Color.inkMuted)
    }
}
