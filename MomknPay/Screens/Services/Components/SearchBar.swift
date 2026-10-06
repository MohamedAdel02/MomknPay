//
//  SearchBar.swift
//  MomknPay
//
//  Created by Mohamed Adel on 05/10/2026.
//

import SwiftUI

struct SearchBar: View {

    @Binding var text: String
    var isFocused: FocusState<Bool>.Binding

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color.inkMuted)
            TextField(
                "Search services",
                text: $text,
                prompt: Text("Search services").foregroundColor(Color.inkMuted).bold()
            )
            .foregroundStyle(Color.ink)
            .bold()
            .focused(isFocused)
            .submitLabel(.search)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
        }
        .padding(.horizontal, 16)
        .frame(height: 52)
        .background(.white, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color.inkMuted.opacity(0.1)))
    }
}

