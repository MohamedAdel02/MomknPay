//
//  PaymentFailureView.swift
//  MomknPay
//
//  Created by Mohamed Adel on 18/10/2026.
//

import SwiftUI

struct PaymentFailureView: View {

    let failure: PaymentFailure

    @Environment(\.popToRoot) private var popToRoot
    @Environment(\.dismiss) private var dismiss
    @State private var copied = false

    var body: some View {
        VStack(spacing: 16) {
            header

            ScrollView {
                VStack(spacing: 16) {
                    reasonCard
                    Spacer()
                    if failure.canRetry {
                        PrimaryButton("Try again") {
                            dismiss()
                        }
                    }
                    homeButton
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            }
        }
        .containerBackground(Color.ground, for: .navigation)
        .navigationBarBackButtonHidden()
    }


    private var header: some View {
        VStack(spacing: 14) {
            Image(systemName: failure.symbolName)
                .font(.system(size: 25, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 75, height: 75)
                .background(Color.white.opacity(0.3), in: Circle())

            Text(failure.title)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(
            UnevenRoundedRectangle(bottomLeadingRadius: 60, bottomTrailingRadius: 40)
                .fill(Color.appPrimary)
                .ignoresSafeArea(edges: .top)
        )
    }


    private var reasonCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(failure.message)
                .font(.system(size: 17))
                .foregroundStyle(Color.ink)
                .fixedSize(horizontal: false, vertical: true)

            if let reference = failure.reference {
                Divider().overlay(Color.inkMuted.opacity(0.3))

                HStack {
                    Text("Reference")
                        .font(.system(size: 15))
                        .foregroundStyle(Color.inkMuted)
                    Spacer()
                    Text(reference)
                        .font(.plexMono(16, weight: .medium))
                        .foregroundStyle(Color.ink)
                    copyButton(reference)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 24))
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.inkMuted.opacity(0.3)))
    }

    private func copyButton(_ reference: String) -> some View {
        Button {
            UIPasteboard.general.string = reference
            copied = true
            Task {
                try? await Task.sleep(for: .seconds(1.5))
                copied = false
            }
        } label: {
            Image(systemName: copied ? "checkmark" : "doc.on.doc")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(copied ? Color.success : Color.inkMuted)
                .frame(width: 40, height: 40)
                .background(Color.inkMuted.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
        }
    }

    private var homeButton: some View {
        Button {
            popToRoot()
        } label: {
            Text("Back to home")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.ink)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
        }
    }
}

#Preview("Declined") {
    PaymentFailureView(failure: .declined(reference: "MP-20260920-5521"))
}

#Preview("Unconfirmed") {
    PaymentFailureView(failure: .unconfirmed)
}
