//
//  DetailRow.swift
//  MomknPay
//
//  Created by Mohamed Adel on 28/09/2026.
//

import SwiftUI

struct DetailRow<Value: View>: View {

    let title: String
    let value: Value

    init(_ title: String, @ViewBuilder value: () -> Value) {
        self.title = title
        self.value = value()
    }

    init(_ title: String, value: String, font: Font = .plexMono(20, weight: .medium)) where Value == Text {
        self.title = title
        self.value = Text(value).font(font)
    }

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 17))
                .foregroundStyle(Color.inkMuted)
            Spacer()
            value
                .foregroundStyle(Color.ink)
        }
    }
}
