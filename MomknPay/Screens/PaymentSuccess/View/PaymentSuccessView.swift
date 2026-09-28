//
//  PaymentSuccessView.swift
//  MomknPay
//
//  Created by Mohamed Adel on 28/09/2026.
//

import SwiftUI

struct PaymentSuccessView: View {

    @State private var copied = false

    var body: some View {
        VStack(spacing: 16) {
            header
            
            ScrollView {
                VStack(spacing: 16) {
                    detailsCard
                    savedNote
                    Spacer()
                    shareButton
                    doneButton
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            }
        }
        .navigationBarBackButtonHidden()
    }


    private var header: some View {
        VStack(spacing: 14) {
            Image(systemName: "checkmark")
                .font(.system(size: 25, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 75, height: 75)
                .background(Color.white.opacity(0.2), in: Circle())

            Text("Payment successful")
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(.white.opacity(0.9))

            HStack(alignment: .lastTextBaseline, spacing: 8) {
                Text("253.20")
                    .font(.plexMono(46, weight: .medium))
                Text("EGP")
                    .font(.system(size: 17, weight: .medium))
                    .opacity(0.85)
            }
            .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            UnevenRoundedRectangle(bottomLeadingRadius: 60, bottomTrailingRadius: 40)
                .fill(Color.success)
                .ignoresSafeArea(edges: .top)
        )
    }


    private var detailsCard: some View {
        VStack(spacing: 18) {
            DetailRow("Service", value: "Cairo Electricity", font: .system(size: 18, weight: .bold))
            DetailRow("Subscriber", value: "1024750891", font: .plexMono(17, weight: .medium))
            DetailRow("Paid at", value: "20 Sep 2026, 19:31", font: .system(size: 16, weight: .semibold))

            Divider().overlay(Color.inkMuted.opacity(0.3))

            DetailRow("Reference") {
                HStack(spacing: 12) {
                    Text("MP-20260920-5521")
                        .font(.plexMono(16, weight: .medium))
                    copyButton
                }
            }
        }
        .padding(20)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 24))
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.inkMuted.opacity(0.3)))
    }


    private var copyButton: some View {
        Button {
            UIPasteboard.general.string = "MP-20260920-5521"
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


    private var savedNote: some View {
        HStack(spacing: 14) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 20))
                .foregroundStyle(Color.success)
            VStack(alignment: .leading, spacing: 2) {
                Text("Saved to your history")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Color.ink)
                Text("Retrying this payment will not charge you twice")
                    .font(.system(size: 15))
                    .foregroundStyle(Color.inkMuted)
            }
            Spacer(minLength: 0)
        }
        .padding(18)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.inkMuted.opacity(0.3)))
    }


    private var shareButton: some View {
        ShareLink(item: "Payment receipt\nCairo Electricity\nAmount: 253.20 EGP\nReference: MP-20260920-5521") {
            Label("Share receipt", systemImage: "square.and.arrow.up")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color.ink)
                .frame(maxWidth: .infinity)
                .frame(height: 58)
                .background(Color.white, in: RoundedRectangle(cornerRadius: 20))
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.inkMuted.opacity(0.3)))
        }
    }


    private var doneButton: some View {
        PrimaryButton("Done") {
            
        }
    }


}

#Preview {
        PaymentSuccessView()
}
