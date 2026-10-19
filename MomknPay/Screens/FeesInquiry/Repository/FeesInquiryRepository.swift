//
//  FeesInquiryRepository.swift
//  MomknPay
//
//  Created by Mohamed Adel on 29/09/2026.
//

import Foundation

protocol FeesInquiryRepositoryProtocol {
    func inquire(service: Service, subscriberNumber: String) async throws -> InquiryResponse
}

struct FeesInquiryRepository: FeesInquiryRepositoryProtocol {

    private let payloadField = "subscriberNumber"

    func inquire(service: Service, subscriberNumber: String) async throws -> InquiryResponse {
        let session = try await SessionManager.shared.currentSession()

        do {
            return try await send(service: service, subscriberNumber: subscriberNumber, using: session)
        } catch NetworkError.api(let code, _, _) where code == .sessionExpired {
            SessionManager.shared.invalidate()
            let fresh = try await SessionManager.shared.currentSession()
            return try await send(service: service, subscriberNumber: subscriberNumber, using: fresh)
        }
    }

    private func send(service: Service,
                      subscriberNumber: String,
                      using session: CryptoSession) async throws -> InquiryResponse {
        let payload = try EncryptionManager.encrypt(field: payloadField,
                                                    value: subscriberNumber,
                                                    key: session.key)
        let body = InquiryRequest(serviceId: service.id, payload: payload)
        let request = try Endpoint.inquiry(body, sessionId: session.id).asHTTPRequest()
        return try await NetworkManager.shared.send(request, as: InquiryResponse.self)
    }
}

// MARK: - Mock

struct MockFeesInquiryRepository: FeesInquiryRepositoryProtocol {

    func inquire(service: Service, subscriberNumber: String) async throws -> InquiryResponse {
        try await Task.sleep(for: .seconds(1))
        return InquiryResponse(
            inquiryId: "inq_8f21",
            serviceId: service.id,
            customerName: "Mohamed Adel",
            billMonth: "2026-08",
            amountDue: 24750,
            serviceFee: 500,
            vat: 70,
            total: 25320,
            currency: "EGP",
            expiresAt: Date().addingTimeInterval(300)
        )
    }
}
