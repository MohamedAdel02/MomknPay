//
//  NetworkHelper.swift
//  MomknPay
//
//

import Foundation

enum APIEnvironment {
 
    case production
 
    var baseURL: String {
        switch self {
        case .production:
            return "https://momkn.ahmedsayed.net/"
        }
    }
 
    var version: String {
        switch self {
        case .production:
            return "v1"
        }
    }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

struct HTTPRequest {
    var url: URL
    var method: HTTPMethod = .get
    var body: Data?
    var headers: [String: String] = [:]
}

enum Endpoint {

    // Services
    case services

    // Ads
    case ads

    // Sessions
    case createSession

    // Payments
    case inquiry(InquiryRequest, sessionId: String)
    case confirm(ConfirmRequest, sessionId: String, idempotencyKey: String)

    private var environment: APIEnvironment { .production }

    private var method: HTTPMethod {
        switch self {
        case .inquiry, .confirm, .createSession: return .post
        case .services, .ads:                    return .get
        }
    }

    private var path: String {
        switch self {
        case .services:      return "services"
        case .ads:           return "ads"
        case .createSession: return "sessions"
        case .inquiry:       return "payments/inquiry"
        case .confirm:       return "payments/confirm"
        }
    }

    private func encodedBody() throws -> Data? {
        switch self {
        case .inquiry(let body, _):     return try JSONEncoder().encode(body)
        case .confirm(let body, _, _):  return try JSONEncoder().encode(body)
        case .services, .ads, .createSession: return nil
        }
    }

    private var headers: [String: String] {
        switch self {
        case .inquiry(_, let sessionId): return ["X-Session-Id": sessionId]
        case .confirm(_, let sessionId, let idempotencyKey):
            return ["X-Session-Id": sessionId, "Idempotency-Key": idempotencyKey]
        case .services, .ads, .createSession: return [:]
        }
    }

    func asHTTPRequest() throws -> HTTPRequest {

        let baseURL = environment.baseURL + environment.version + "/"

        guard let url = URL(string: baseURL + path), url.scheme == "https" else {
            throw NetworkError.invalidURL
        }

        return HTTPRequest(url: url, method: method, body: try encodedBody(), headers: headers)
    }

}
