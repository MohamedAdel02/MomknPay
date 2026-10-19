//
//  Payment.swift
//  MomknPay
//
//  Created by Mohamed Adel on 18/10/2026.
//

import Foundation

struct ConfirmRequest: Encodable {
    let inquiryId: String
    let payload: String
}

enum PaymentStatus: String, Decodable, Hashable {
    case success = "SUCCESS"
    case failed  = "FAILED"
    case pending = "PENDING"
}

struct ConfirmResponse: Decodable, Hashable {

    struct ServiceInfo: Decodable, Hashable {
        let id: String
        let nameEn: String
    }

    let transactionId: String
    let status: PaymentStatus
    let reference: String
    let paidAt: Date
    let total: Int
    let service: ServiceInfo

    var totalText: String {
        (Decimal(total) / 100).formatted(.number.precision(.fractionLength(2)))
    }
}

extension ConfirmResponse {
    static func sample(status: PaymentStatus = .success) -> ConfirmResponse {
        ConfirmResponse(transactionId: "txn_5521",
                        status: status,
                        reference: "MP-20260920-5521",
                        paidAt: Date(),
                        total: 25320,
                        service: ServiceInfo(id: "svc_elec_cairo", nameEn: "Cairo Electricity"))
    }
}


enum PaymentResult: Hashable {
    case success(ConfirmResponse)
    case failure(PaymentFailure)
}

struct PaymentFailure: Hashable {
    let title: String
    let message: String
    let symbolName: String
    let reference: String?
    let canRetry: Bool
 
    static func declined(reference: String?) -> PaymentFailure {
        PaymentFailure(title: String(localized: "Payment failed"),
                       message: String(localized: "Your payment was declined."),
                       symbolName: "xmark",
                       reference: reference,
                       canRetry: true)
    }
 
    static func pending(reference: String?) -> PaymentFailure {
        PaymentFailure(title: String(localized: "Payment pending"),
                       message: String(localized: "We're still processing your payment. Please wait a few minutes before trying again."),
                       symbolName: "clock",
                       reference: reference,
                       canRetry: false)
    }
 
    /// The request may or may not have reached the server, so the outcome is unknown.
    static var unconfirmed: PaymentFailure {
        PaymentFailure(title: String(localized: "We couldn't confirm your payment"),
                       message: String(localized: "Wait a few minutes before trying again."),
                       symbolName: "exclamationmark.triangle",
                       reference: nil,
                       canRetry: false)
    }
 
    static func from(_ error: NetworkError) -> PaymentFailure {
        switch error {
        case .timeout, .noConnectivity, .server:
            return .unconfirmed
 
        case .api(let code, _, _):
            let retryable = code != .inquiryExpired && code != .insufficientBalance
            return PaymentFailure(title: String(localized: "Payment failed"),
                                  message: error.errorDescription ?? code.fallbackText,
                                  symbolName: "xmark",
                                  reference: nil,
                                  canRetry: retryable)
 
        default:
            return PaymentFailure(title: String(localized: "Payment failed"),
                                  message: error.errorDescription ?? String(localized: "Something went wrong. Please try again."),
                                  symbolName: "xmark",
                                  reference: nil,
                                  canRetry: true)
        }
    }
}
 
