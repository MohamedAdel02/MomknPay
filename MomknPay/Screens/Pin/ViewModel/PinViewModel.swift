//
//  PinViewModel.swift
//  MomknPay
//
//  Created by Mohamed Adel on 09/10/2026.
//


import Foundation

@Observable
class PinViewModel {

    let amountText: String
    let serviceName: String
    let pinLength = 4

    var pin = ""
    var isVerifying = false
    var showError = false
    var isVerified = false
    var shakeCount = 0

    /// Checks the PIN. Always true for now; swap in the real call later.
    private let verifyPin: (String) async -> Bool
    
    /// Checks biometrics. Always true for now.
    private let verifyBiometric: () async -> Bool
    
    /// Called once, after the PIN has been verified.
    private let onVerified: () -> Void

    init(amountText: String,
         serviceName: String,
         verifyBiometric: @escaping () async -> Bool = { true },
         verifyPin: @escaping (String) async -> Bool = { _ in true },
         onVerified: @escaping () -> Void
    ) {
        self.amountText = amountText
        self.serviceName = serviceName
        self.verifyPin = verifyPin
        self.verifyBiometric = verifyBiometric
        self.onVerified = onVerified
    }

    var canConfirm: Bool { pin.count == pinLength && !isVerifying }
    var isInputDisabled: Bool { isVerifying || isVerified }

    func append(_ digit: String) {
        guard !isInputDisabled, pin.count < pinLength else { return }
        showError = false
        pin += digit
    }

    func deleteLast() {
        guard !isInputDisabled, !pin.isEmpty else { return }
        showError = false
        pin.removeLast()
    }

    func confirm() async {
        guard canConfirm else { return }
        await run { await self.verifyPin(self.pin) }
    }

    func confirmWithBiometrics() async {
        guard !isInputDisabled else { return }
        await run { await self.verifyBiometric() }
    }

    private func run(_ check: () async -> Bool) async {
        isVerifying = true
        let isValid = await check()
        isVerifying = false

        if isValid {
            isVerified = true
            onVerified()
        } else {
            pin = ""
            showError = true
            shakeCount += 1
        }
    }
}
