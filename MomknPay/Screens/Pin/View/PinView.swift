//
//  PinView.swift
//  MomknPay
//
//  Created by Mohamed Adel on 09/10/2026.
//

import SwiftUI

struct PinView: View {

    @State var viewModel: PinViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var contentHeight: CGFloat = 520

    private let rows: [[String]] = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"]
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            dragIndicator
            titleBar
            subtitle
            dots
            keypad
            confirmButton
            footerNote
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 12)
        .onGeometryChange(for: CGFloat.self) { proxy in
            proxy.size.height
        } action: { newHeight in
            contentHeight = newHeight
        }
        .presentationDetents([.height(contentHeight)])
        .presentationDragIndicator(.hidden)
        .presentationCornerRadius(32)
        .presentationBackground(Color.ground)
        .interactiveDismissDisabled(viewModel.isVerifying)
        .onChange(of: viewModel.isVerified) { _, verified in
            if verified { dismiss() }
        }
    }
    
    private var dragIndicator: some View {
        
        Capsule()
            .fill(Color.inkMuted.opacity(0.35))
            .frame(width: 40, height: 5)
            .frame(maxWidth: .infinity)
            .padding(.top, 16)
            .padding(.bottom, 4)
    }

    private var titleBar: some View {
        
        Text("Enter your PIN")
            .font(.system(size: 22, weight: .bold))
            .foregroundStyle(Color.ink)
    }

    private var subtitle: some View {
        Group {
            if viewModel.showError {
                Text("Incorrect PIN. Please try again.")
                    .foregroundStyle(Color.warning)
            } else {
                Text("Paying \(Text("\(viewModel.amountText) EGP").bold().foregroundColor(.ink)) to \(viewModel.serviceName)")
            }
        }
        .font(.system(size: 17))
        .foregroundStyle(Color.inkMuted)
    }

    private var dots: some View {
        HStack(spacing: 26) {
            ForEach(0..<viewModel.pinLength, id: \.self) { index in
                let filled = index < viewModel.pin.count
                Circle()
                    .fill(filled ? Color.ink : Color.clear)
                    .overlay(Circle().stroke(Color.inkMuted.opacity(0.6), lineWidth: filled ? 0 : 1))
                    .frame(width: 24, height: 24)
            }
        }
        .frame(maxWidth: .infinity)
        .phaseAnimator([0, 10, -10, 10, -10, 0], trigger: viewModel.shakeCount) { content, offset in
            content.offset(x: offset)
        } animation: { _ in
            .linear(duration: 0.04)
        }
    }

    private var keypad: some View {
        VStack(spacing: 14) {
            ForEach(rows, id: \.self) { row in
                HStack(spacing: 18) {
                    ForEach(row, id: \.self) { digit in
                        digitKey(digit)
                    }
                }
            }
            
            HStack(spacing: 18) {
                biometricKey
                digitKey("0")
                deleteKey
            }
        }
    }

    private func digitKey(_ digit: String) -> some View {
        Button {
            viewModel.append(digit)
        } label: {
            Text(digit)
                .font(.plexMono(28, weight: .medium))
                .foregroundStyle(Color.ink)
                .frame(maxWidth: .infinity)
                .frame(height: 66)
                .background(Color.white, in: RoundedRectangle(cornerRadius: 16))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.inkMuted.opacity(0.2)))
        }
        .disabled(viewModel.isInputDisabled)
    }

    private var biometricKey: some View {
        Button {
            Task { await viewModel.confirmWithBiometrics() }
        } label: {
            Image(systemName: "faceid")
                .font(.system(size: 26))
                .foregroundStyle(Color.inkMuted)
                .frame(maxWidth: .infinity)
                .frame(height: 66)
        }
        .disabled(viewModel.isInputDisabled)
    }

    private var deleteKey: some View {
        Button {
            viewModel.deleteLast()
        } label: {
            Image(systemName: "delete.left")
                .font(.system(size: 24))
                .foregroundStyle(Color.ink)
                .frame(maxWidth: .infinity)
                .frame(height: 66)
        }
        .disabled(viewModel.isInputDisabled)
    }

    private var confirmButton: some View {
        PrimaryButton("Confirm payment") {
            Task { await viewModel.confirm() }
        }
        .disabled(!viewModel.canConfirm)
        .opacity(viewModel.canConfirm ? 1 : 0.5)
    }

    private var footerNote: some View {
        Label("PIN is encrypted and never stored on the device", systemImage: "lock")
            .font(.system(size: 14))
            .foregroundStyle(Color.inkMuted)
            .frame(maxWidth: .infinity)
    }
}

#Preview {
    Color.gray
        .sheet(isPresented: .constant(true)) {
            PinView(viewModel: PinViewModel(
                amountText: "253.20",
                serviceName: "Cairo Electricity",
                onVerified: { }
            ))
        }
}
