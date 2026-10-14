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
            return "https://api.momknpay.local/"
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

    // Payments
    case inquiry(InquiryRequest)

    private var environment: APIEnvironment { .production }

    private var method: HTTPMethod {
        switch self {
        case .inquiry:
            return .post
        case .services:
            return .get
        }
    }

    private var path: String {
        switch self {
        case .services: return "services"
        case .inquiry:  return "payments/inquiry"
        }
    }

    private func encodedBody() throws -> Data? {
        switch self {
        case .inquiry(let body): return try JSONEncoder().encode(body)
        case .services:          return nil
        }
    }

    
    func asHTTPRequest() throws -> HTTPRequest {
        
        let baseURL = environment.baseURL + environment.version + "/"
        
        guard let url = URL(string: baseURL + path), url.scheme == "https" else {
            throw NetworkError.invalidURL
        }
        
        return HTTPRequest(url: url, method: method, body: try encodedBody())
    }

}
