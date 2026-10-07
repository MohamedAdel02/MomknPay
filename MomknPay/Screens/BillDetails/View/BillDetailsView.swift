//
//  BillDetailsView.swift
//  MomknPay
//
//  Created by Mohamed Adel on 24/09/2026.
//

import SwiftUI

struct BillDetailsView: View {

    @State var viewModel: BillDetailsViewModel
    @State private var showSuccess = false
    @State private var showExpiredAlert = false
    @Environment(\.dismiss) private var dismiss
    
    @Environment(\.showToast) private var showToast
    @Environment(\.popToRoot) private var popToRoot

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
        .onChange(of: viewModel.isExpired) { _, expired in
            if expired { showExpiredAlert = true }
        }
        .alert("Quote expired", isPresented: $showExpiredAlert) {
            Button("OK") { popToRoot() }
        } message: {
            Text("Your quote has expired. Please start again.")
        }
    }

    private var expiryBanner: some View {
        let color = viewModel.isExpired ? Color.warning : Color.appPrimary

        return HStack {
            Label(viewModel.isExpired ? "Quote expired" : "Quote expires in", systemImage: "clock")
                .font(.system(size: 15, weight: .semibold))
            Spacer()
            Text(viewModel.formattedCountdown)
                .font(.plexMono(17, weight: .medium))
        }
        .foregroundStyle(color)
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(color.opacity(0.05), in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(color.opacity(0.3)))
    }

    private var billCard: some View {
        VStack(spacing: 0) {
            HStack(spacing: 14) {
                ServiceIcon(service: viewModel.service)
                VStack(alignment: .leading, spacing: 2) {
                    Text(viewModel.service.nameEn)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Color.ink)
                    Text(viewModel.subscriberNumber)
                        .font(.plexMono(16))
                        .foregroundStyle(Color.inkMuted)
                }
                Spacer()
            }
            .padding(20)

            Divider().overlay(Color.inkMuted)

            VStack(spacing: 16) {
                DetailRow("Customer", value: viewModel.inquiry.customerName, font: .system(size: 17, weight: .bold))
                DetailRow("Bill month", value: viewModel.billMonthText, font: .system(size: 17, weight: .bold))
                Divider().overlay(Color.inkMuted)

                DetailRow("Amount due", value: viewModel.amountDueText)
                DetailRow("Service fee", value: viewModel.serviceFeeText)
                DetailRow("VAT (14% of fee)", value: viewModel.vatText)
                Divider().overlay(Color.inkMuted)

                HStack(alignment: .lastTextBaseline) {
                    Text("Total")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.ink)
                    Spacer()
                    Text(viewModel.totalText)
                        .font(.plexMono(36, weight: .medium))
                        .foregroundStyle(Color.ink)
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)
                    Text(viewModel.currency)
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
        PrimaryButton("Pay \(viewModel.totalText) \(viewModel.currency)") {
            showSuccess = true
        }
        .disabled(viewModel.isExpired)
        .opacity(viewModel.isExpired ? 0.5 : 1)
    }

    private var cancelButton: some View {
        Button(viewModel.isExpired ? "Back" : "Cancel") {
            dismiss()
        }
        .font(.system(size: 16, weight: .semibold))
        .foregroundStyle(Color.inkMuted)
    }
}

