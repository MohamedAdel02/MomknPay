//
//  MessageStateView.swift
//  MomknPay
//
//  Created by Mohamed Adel on 04/10/2026.
//

import SwiftUI

struct MessageStateView: View {

    let systemImage: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 40))
                .foregroundStyle(Color.inkMuted)

            Text(title)
                .font(.headline)
                .foregroundStyle(Color.ink)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(Color.inkMuted)
                .multilineTextAlignment(.center)

            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(.borderedProminent)
                    .tint(Color.ink)
                    .padding(.top, 4)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
