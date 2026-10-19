//
//  PinRepository.swift
//  MomknPay
//
//  Created by Mohamed Adel on 18/10/2026.
//

import Foundation

protocol PinRepositoryProtocol {
    func confirm(inquiryId: String, pin: String, idempotencyKey: String) async throws -> ConfirmResponse
}

struct PinRepository: PinRepositoryProtocol {

    func confirm(inquiryId: String, pin: String, idempotencyKey: String) async throws -> ConfirmResponse {
        let session = try await SessionManager.shared.currentSession()

        do {
            return try await send(inquiryId: inquiryId, pin: pin, idempotencyKey: idempotencyKey, session: session)
        } catch NetworkError.api(let code, _, _) where code == .sessionExpired {

            SessionManager.shared.invalidate()
            let fresh = try await SessionManager.shared.currentSession()
            return try await send(inquiryId: inquiryId, pin: pin, idempotencyKey: idempotencyKey, session: fresh)
        }
    }

    private func send(inquiryId: String,
                      pin: String,
                      idempotencyKey: String,
                      session: CryptoSession) async throws -> ConfirmResponse {
        let payload = try EncryptionManager.encrypt(field: "pin", value: pin, key: session.key)
        let body = ConfirmRequest(inquiryId: inquiryId, payload: payload)
        let request = try Endpoint
            .confirm(body, sessionId: session.id, idempotencyKey: idempotencyKey)
            .asHTTPRequest()
        return try await NetworkManager.shared.send(request, as: ConfirmResponse.self)
    }
}


struct MockPinRepository: PinRepositoryProtocol {

    func confirm(inquiryId: String, pin: String, idempotencyKey: String) async throws -> ConfirmResponse {
        try await Task.sleep(for: .seconds(1))

        switch pin {
        case "0000": throw NetworkError.api(code: .invalidPin, message: nil, field: nil)
        case "1111": return .sample(status: .failed)
        case "2222": throw NetworkError.timeout
        default:     return .sample()
        }
    }
}
