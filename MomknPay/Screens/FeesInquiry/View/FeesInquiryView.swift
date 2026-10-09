//
//  FeesInquiryView.swift
//  MomknPay
//
//  Created by Mohamed Adel on 29/09/2026.
//

import SwiftUI
import Kingfisher

struct FeesInquiryView: View {
 
    @State var viewModel: FeesInquiryViewModel
    @FocusState private var isFocused: Bool
 
    var body: some View {
        VStack(spacing: 24) {
 
            providerCard
 
            VStack(alignment: .leading, spacing: 10) {
                Text(viewModel.service.inputLabel)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.inkMuted)
 
                subscriberField
 
                feedback
            }
 
            Spacer()
 
            PrimaryButton(viewModel.isLoading ? "" : "Check My Bill") {
                isFocused = false
                Task { await viewModel.submit() }
            }
            .disabled(!viewModel.canSubmit)
            .opacity(viewModel.canSubmit || viewModel.isLoading ? 1 : 0.5)
            .overlay {
                if viewModel.isLoading {
                    ProgressView().tint(.white)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .contentShape(Rectangle())
        .onTapGesture { isFocused = false }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Fees Inquiry")
                    .font(.headline)
                    .foregroundStyle(Color.ink)
            }
        }
        .tint(Color.ink)
        .containerBackground(Color.ground, for: .navigation)
        .navigationDestination(item: $viewModel.inquiry) { inquiry in
            BillDetailsView(viewModel: BillDetailsViewModel( inquiry: inquiry, service: viewModel.service, subscriberNumber: viewModel.rawDigits))
        }
    }
 
 
    private var providerCard: some View {
        HStack(spacing: 14) {
            ServiceIcon(service: viewModel.service)
 
            Text(viewModel.service.nameEn)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Color.ink)
 
            Spacer()
        }
        .padding(16)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.ink.opacity(0.1)))
    }
 
 
    private var subscriberField: some View {
        TextField("",
                  text: $viewModel.displayText,
                  prompt: Text("10-digit number")
                            .font(.system(size: 18))
                            .foregroundColor(Color.inkMuted.opacity(0.5))
            )
            .keyboardType(.numberPad)
            .focused($isFocused)
            .disabled(viewModel.isLoading)
            .font(.plexMono(28, weight: .medium))
            .foregroundStyle(Color.ink)
            .padding(.horizontal, 18)
            .frame(height: 64)
            .background(Color.white, in: RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(borderColor, lineWidth: 1.5)
            )
            .onChange(of: viewModel.displayText) {
                viewModel.formatSubscriberNumber()
            }
    }
 
    private var borderColor: Color {
        viewModel.errorMessage == nil ? Color.ink.opacity(0.5) : Color.warning
    }
 
    @ViewBuilder
    private var feedback: some View {
        if let message = viewModel.errorMessage {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.circle")
                    .font(.system(size: 14))
                Text(message)
                    .font(.system(size: 14))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .foregroundStyle(Color.warning)
        } else {
            HStack(spacing: 8) {
                Image(systemName: "info.circle")
                    .font(.system(size: 14))
                Text("10 digits, printed at the top of your bill")
                    .font(.system(size: 14))
            }
            .foregroundStyle(Color.inkMuted)
        }
    }
}
 
