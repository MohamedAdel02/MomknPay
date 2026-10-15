//
//  PinViewModel.swift
//  MomknPay
//
//  Created by Mohamed Adel on 09/10/2026.
//

import Foundation
import LocalAuthentication

@Observable
class PinViewModel {

    let amountText: String
    let serviceName: String
    let pinLength = 4
    let biometryType: LABiometryType

    var pin = ""
    var showBiometricUnavailableAlert = false
    var isVerifying = false
    var showError = false
    var isVerified = false
    var shakeCount = 0

    /// Checks the PIN. Always true for now; swap in the real call later.
    private let verifyPin: (String) async -> Bool

    /// Checks biometrics via LocalAuthentication.
    private let verifyBiometric: () async -> BiometricResult

    /// Called once, after the payment has been verified (PIN or biometrics).
    private let onVerified: () -> Void

    init(amountText: String,
         serviceName: String,
         biometryType: LABiometryType = BiometricAuthenticator.availableType,
         verifyBiometric: @escaping () async -> BiometricResult = {
             await BiometricAuthenticator.authenticate(reason: "Confirm your payment")
         },
         verifyPin: @escaping (String) async -> Bool = { _ in true },
         onVerified: @escaping () -> Void
    ) {
        self.amountText = amountText
        self.serviceName = serviceName
        self.biometryType = biometryType
        self.verifyPin = verifyPin
        self.verifyBiometric = verifyBiometric
        self.onVerified = onVerified
    }

    var canConfirm: Bool { pin.count == pinLength && !isVerifying }
    var isInputDisabled: Bool { isVerifying || isVerified }
    var canUseBiometrics: Bool { biometryType != .none }

    /// SF Symbol for the current biometry type, nil when unavailable.
    var biometricIcon: String? {
        switch biometryType {
        case .faceID:  "faceid"
        case .touchID: "touchid"
        case .opticID: "opticid"
        default:       nil
        }
    }


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
        isVerifying = true
        let isValid = await verifyPin(pin)
        isVerifying = false

        if isValid {
            complete()
        } else {
            pin = ""
            showError = true
            shakeCount += 1
        }
    }

    func confirmWithBiometrics() async {
        guard canUseBiometrics, !isInputDisabled else { return }
        isVerifying = true
        let result = await verifyBiometric()
        isVerifying = false

        switch result {
        case .success:             complete()
        case .unavailable:         showBiometricUnavailableAlert = true
        case .cancelled, .failed:  break
        }
    }

    private func complete() {
        isVerified = true
        onVerified()
    }
}
