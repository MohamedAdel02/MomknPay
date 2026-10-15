//
//  BiometricAuthenticator.swift
//  MomknPay
//
//  Created by Mohamed Adel on 15/10/2026.
//

import LocalAuthentication

enum BiometricResult {
    case success
    case cancelled     // user backed out / choose PIN
    case unavailable   // denied in Settings, not enrolled, or locked out
    case failed
}

enum BiometricAuthenticator {
    
    static var availableType: LABiometryType {
        let context = LAContext()
        var error: NSError?
        _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        return context.biometryType
    }

    static func authenticate(reason: String) async -> BiometricResult {
        let context = LAContext()
        context.localizedCancelTitle = "Use PIN"

        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else { return .unavailable }

        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            )
            return success ? .success : .failed
        } catch let error as LAError {
            switch error.code {
            case .userCancel, .userFallback, .appCancel, .systemCancel, .biometryNotAvailable:
                return .cancelled
            case .biometryNotEnrolled, .biometryLockout:
                return .unavailable
            default:
                return .failed
            }
        } catch {
            return .failed
        }
    }
}
