//
//  Font+Extensions.swift
//  MomknPay
//
//  Created by Mohamed Adel on 25/09/2026.
//

import SwiftUI

extension Font {
    static func plexMono(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        let name: String
        switch weight {
        case .medium:
            name = "IBMPlexMono-Medium"
        case .semibold:
            name = "IBMPlexMono-SemiBold"
        case .bold:
            name = "IBMPlexMono-Bold"
        default:
            name = "IBMPlexMono-Regular"
        }
        return .custom(name, size: size)
    }
}
