//
//  SessionManager.swift
//  MomknPay
//
//  Created by Mohamed Adel on 18/10/2026.
//

import Foundation
import CryptoKit


struct CryptoSession {
    let id: String
    let key: SymmetricKey
    let expiresAt: Date

    /// Treat it as expired 60s early so we never use a key mid-expiry.
    var isUsable: Bool { expiresAt.timeIntervalSinceNow > 60 }
}

class SessionManager {

    static let shared = SessionManager()

    private var session: CryptoSession?
    private var fetchTask: Task<CryptoSession, Error>?

    /// Returns a valid session, fetching a new one only if needed.
    func currentSession() async throws -> CryptoSession {
        if let session, session.isUsable { return session }
        if let fetchTask { return try await fetchTask.value }

        let task = Task { try await self.fetchSession() }
        fetchTask = task
        defer { fetchTask = nil }

        let fresh = try await task.value
        session = fresh
        return fresh
    }

    /// Drops the cached session (e.g. the server rejected it); the next call fetches a new one.
    func invalidate() {
        session = nil
    }

    private func fetchSession() async throws -> CryptoSession {

        let request = try Endpoint.createSession.asHTTPRequest()
        let response = try await NetworkManager.shared.send(request, as: SessionResponse.self)

        guard let keyData = Data(base64Encoded: response.sessionKey), keyData.count == 32 else {
            throw NetworkError.decoding("Invalid session key")
        }

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let expiry = formatter.date(from: response.expiresAt) ?? Date().addingTimeInterval(30 * 60)

        return CryptoSession(id: response.sessionId, key: SymmetricKey(data: keyData), expiresAt: expiry)
    }
}
