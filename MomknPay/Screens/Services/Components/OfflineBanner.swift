//
//  OfflineBanner.swift
//  MomknPay
//
//  Created by Mohamed Adel on 04/10/2026.
//

import SwiftUI

struct OfflineBanner: View {

    let syncedAt: Date

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "wifi.slash")
                .font(.subheadline.weight(.semibold))

            Text("Offline — showing saved list")
                .font(.subheadline.weight(.bold))
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Spacer(minLength: 8)

            Text(Self.ago(syncedAt))
                .font(.subheadline)
        }
        .foregroundStyle(Color.warning)
        .padding(.horizontal, 16)
        .frame(height: 52)
        .background(Color.warning.opacity(0.12), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color.warning.opacity(0.3)))
        .accessibilityElement(children: .combine)
    }

    static func ago(_ date: Date, now: Date = Date()) -> String {
        let seconds = max(0, now.timeIntervalSince(date))
        switch seconds {
        case ..<60:       return String(localized: "just now")
        case ..<3600:     return String(localized: "\(Int(seconds / 60))m ago")
        case ..<86_400:   return String(localized: "\(Int(seconds / 3600))h ago")
        default:          return String(localized: "\(Int(seconds / 86_400))d ago")
        }
    }
}


