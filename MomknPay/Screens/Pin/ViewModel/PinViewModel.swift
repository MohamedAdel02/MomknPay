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

    static let biometricsEnabled = false
    static let useMockData = false
    
    let inquiryId: String
    let amountText: String
    let serviceName: String
    let pinLength = 3
    let biometryType: LABiometryType

    var pin = ""
    var toastMessage: String?
    var showBiometricUnavailableAlert = false
    var isVerifying = false
    var showError = false
    var isVerified = false
    var shakeCount = 0

    private let repository: PinRepositoryProtocol

    /// Checks biometrics via LocalAuthentication.
    private let verifyBiometric: () async -> BiometricResult

    /// Called once, with the final outcome (success or failure).
    private let onFinished: (PaymentResult) -> Void

    /// One key per payment attempt.
    private var idempotencyKey = UUID().uuidString

    init(inquiryId: String,
         amountText: String,
         serviceName: String,
         biometryType: LABiometryType = BiometricAuthenticator.availableType,
         verifyBiometric: @escaping () async -> BiometricResult = {
             await BiometricAuthenticator.authenticate(reason: "Confirm your payment")
         },
         repository: PinRepositoryProtocol = PinViewModel.useMockData ? MockPinRepository() : PinRepository(),
         onFinished: @escaping (PaymentResult) -> Void
    ) {
        self.inquiryId = inquiryId
        self.amountText = amountText
        self.serviceName = serviceName
        self.biometryType = biometryType
        self.verifyBiometric = verifyBiometric
        self.repository = repository
        self.onFinished = onFinished
    }

    var canConfirm: Bool { pin.count == pinLength && !isVerifying }
    var isInputDisabled: Bool { isVerifying || isVerified }
    var canUseBiometrics: Bool { Self.biometricsEnabled && biometryType != .none }

    /// SF Symbol for the current biometry type, nil when unavailable or disabled.
    var biometricIcon: String? {
        guard canUseBiometrics else { return nil }
        switch biometryType {
        case .faceID:  return "faceid"
        case .touchID: return "touchid"
        case .opticID: return "opticid"
        default:       return nil
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


    @MainActor
    func confirm() async {
        guard canConfirm else { return }
        isVerifying = true

        do {
            let response = try await repository.confirm(inquiryId: inquiryId,
                                                            pin: pin,
                                                            idempotencyKey: idempotencyKey)
            isVerifying = false

            switch response.status {
            case .success: finish(.success(response))
            case .failed:  finish(.failure(.declined(reference: response.reference)))
            case .pending: finish(.failure(.pending(reference: response.reference)))
            }
        } catch let error as NetworkError {
            isVerifying = false
            handle(error)
        } catch {
            isVerifying = false
            finish(.failure(.from(.unknown(error.localizedDescription))))
        }
    }

    func confirmWithBiometrics() async {
        guard canUseBiometrics, !isInputDisabled else { return }
        isVerifying = true
        let result = await verifyBiometric()
        isVerifying = false

        switch result {
        case .unavailable:
            showBiometricUnavailableAlert = true
        case .success, .cancelled, .failed:
            break
        }
    }


    private func handle(_ error: NetworkError) {
        if error == .cancelled { return }

        if case .api(let code, _, _) = error {
            switch code {
            case .invalidPin:
                pin = ""
                showError = true
                shakeCount += 1
                idempotencyKey = UUID().uuidString
                return

            case .validation:
                pin = ""
                shakeCount += 1
                toastMessage = String(localized: "Invalid PIN. Please try again.")
                idempotencyKey = UUID().uuidString
                return

            default:
                break
            }
        }

        finish(.failure(.from(error)))
    }

    private func finish(_ result: PaymentResult) {
        isVerified = true
        onFinished(result)
    }
}
