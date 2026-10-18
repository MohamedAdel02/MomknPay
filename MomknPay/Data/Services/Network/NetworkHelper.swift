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

    // Sessions
    case createSession

    // Payments
    case inquiry(InquiryRequest, sessionId: String)

    private var environment: APIEnvironment { .production }

    private var method: HTTPMethod {
        switch self {
        case .inquiry, .createSession: return .post
        case .services:                return .get
        }
    }

    private var path: String {
        switch self {
        case .services:      return "services"
        case .createSession: return "sessions"
        case .inquiry:       return "payments/inquiry"
        }
    }

    private func encodedBody() throws -> Data? {
        switch self {
        case .inquiry(let body, _):     return try JSONEncoder().encode(body)
        case .services, .createSession: return nil
        }
    }

    private var headers: [String: String] {
        switch self {
        case .inquiry(_, let sessionId): return ["X-Session-Id": sessionId]
        case .services, .createSession:  return [:]
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
