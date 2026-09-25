//
//  BillDetailsView.swift
//  MomknPay
//
//  Created by Mohamed Adel on 24/09/2026.
//

import SwiftUI

struct BillDetailsView: View {
    
    @State private var viewModel = BillDetailsViewModel()

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
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .navigationTitle("Bill Details")
        .navigationBarTitleDisplayMode(.inline)
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
                row("Customer", "Mohamed Adel", bold: true)
                row("Bill month", "August 2026", bold: true)
                Divider().overlay(Color.inkMuted)
                
                row("Amount due", "247.50")
                row("Service fee", "5.00")
                row("VAT (14% of fee)", "0.70")
                Divider().overlay(Color.inkMuted)
                
                HStack(alignment: .lastTextBaseline) {
                    Text("Total")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.ink)
                    Spacer()
                    Text("234.54")
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

    private func row(_ title: String, _ value: String, bold: Bool = false) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 17))
                .foregroundStyle(Color.inkMuted)
            Spacer()
            Text(value)
                .font(bold ? .system(size: 17, weight: .bold) : .plexMono(20, weight: .medium))
                .foregroundStyle(Color.ink)
        }
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
        Button {
            
        } label: {
            Text("Pay 253.20 EGP")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 58)
                .background(Color.appPrimary, in: RoundedRectangle(cornerRadius: 20))
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
