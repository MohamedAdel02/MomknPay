//
//  ServiceRow.swift
//  MomknPay
//
//  Created by Mohamed Adel on 05/10/2026.
//

import SwiftUI

struct ServiceRow: View {

    let service: Service

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: 22, style: .continuous)
    }

    var body: some View {
        HStack(spacing: 10) {
            ServiceIcon(service: service)

            VStack(alignment: .leading, spacing: 2) {
                Text(service.nameEn)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(service.available ? Color.ink : Color.inkMuted)

                if !service.nameAr.isEmpty {
                    Text(service.nameAr)
                        .font(.subheadline)
                        .foregroundStyle(Color.inkMuted)
                }
            }
            .lineLimit(1)
            .minimumScaleFactor(0.85)

            Spacer(minLength: 1)

            trailing
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(.white, in: shape)
        .overlay(shape.stroke(Color.inkMuted.opacity(0.15)))
        .opacity(service.available ? 1 : 0.6)
        .accessibilityElement(children: .combine)
    }


    @ViewBuilder
    private var trailing: some View {
        if service.available {
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Color.inkMuted.opacity(0.6))
        } else {
            Text("UNAVAILABLE")
                .font(.caption.bold())
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
                .foregroundStyle(Color.warning)
                .padding(8)
                .background(Color.warning.opacity(0.15), in: Capsule())
        }
    }
}
