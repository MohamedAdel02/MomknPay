//
//  PrimaryButton.swift
//  MomknPay
//
//  Created by Mohamed Adel on 28/09/2026.
//

import SwiftUI

struct PrimaryButton: View {

    let title: String
    let action: () -> Void

    init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 58)
                .background(Color.appPrimary, in: RoundedRectangle(cornerRadius: 20))
        }
    }
}
