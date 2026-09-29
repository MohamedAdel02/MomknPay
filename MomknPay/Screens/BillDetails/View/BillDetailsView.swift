//
//  BillDetailsView.swift
//  MomknPay
//
//  Created by Mohamed Adel on 24/09/2026.
//

import SwiftUI

struct BillDetailsView: View {
    
    @State private var viewModel = BillDetailsViewModel()
    @State private var showSuccess = false

    var body: some View {
        VStack(spacing: 18) {
            
            ScrollView {
                VStack(spacing: 15) {
                    expiryBanner
                    billCard
                    infoNote
                    Spacer()
                }
            }
            payButton
            cancelButton

        }
        .containerBackground(Color.ground, for: .navigation)
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
        .navigationDestination(isPresented: $showSuccess) {
            PaymentSuccessView()
        }
        .onAppear { viewModel.onAppear() }
        .onDisappear { viewModel.onDisappear() }

    }

    private var expiryBanner: some View {
        HStack {
            Label("Quote expires in", systemImage: "clock")
                .font(.system(size: 15, weight: .semibold))
            Spacer()
            Text(viewModel.formattedCountdown)
                .font(.plexMono(17, weight: .medium))
        }
        .foregroundStyle(Color.appPrimary)
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.appPrimary.opacity(0.05), in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.appPrimary.opacity(0.3)))
    }

    private var billCard: some View {
        VStack(spacing: 0) {
            HStack(spacing: 14) {
                Image(systemName: "bolt")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(Color.appPrimary)
                    .frame(width: 56, height: 56)
                    .background(Color.appPrimary.opacity(0.1), in: RoundedRectangle(cornerRadius: 16))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Cairo Electricity")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Color.ink)
                    Text("1024750891")
                        .font(.plexMono(16))
                        .foregroundStyle(Color.inkMuted)
                }
                Spacer()
            }
            .padding(20)

            Divider().overlay(Color.inkMuted)

            VStack(spacing: 16) {
                DetailRow("Customer", value: "Mohamed Adel", font: .system(size: 17, weight: .bold))
                DetailRow("Bill month", value: "August 2026", font: .system(size: 17, weight: .bold))
                Divider().overlay(Color.inkMuted)

                DetailRow("Amount due", value: "247.50")
                DetailRow("Service fee", value: "5.00")
                DetailRow("VAT (14% of fee)", value: "0.70")
                Divider().overlay(Color.inkMuted)

                HStack(alignment: .lastTextBaseline) {
                    Text("Total")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.ink)
                    Spacer()
                    Text("253.20")
                        .font(.plexMono(36, weight: .medium))
                        .foregroundStyle(Color.ink)
                    Text("EGP")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Color.inkMuted)
                }
            }
            .padding(20)
        }
        .background(Color.white, in: RoundedRectangle(cornerRadius: 24))
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.inkMuted))
    }

    private var infoNote: some View {
        Text("Server computes every figure in \(Text("piastres").bold().foregroundColor(.ink)). The client formats, it never calculates.")
            .font(.system(size: 16))
            .foregroundStyle(Color.inkMuted)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.appPrimary.opacity(0.4), style: StrokeStyle(lineWidth: 1, dash: [4]))
            )
    }

    private var payButton: some View {
        PrimaryButton("Pay 253.20 EGP") {
            showSuccess = true
        }
    }
    
    
    private var cancelButton: some View {
        Button("Cancel") {
            
        }
        .font(.system(size: 16, weight: .semibold))
        .foregroundStyle(Color.inkMuted)
        
    }
}

#Preview {
    BillDetailsView()
}
