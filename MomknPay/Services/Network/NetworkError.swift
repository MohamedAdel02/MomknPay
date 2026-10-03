//
//  NetworkError.swift
//  MomknPay
//
//

import Foundation

enum APIErrorCode: String, Equatable {
    case validation          = "VALIDATION_ERROR"
    case unauthorized        = "UNAUTHORIZED"
    case subscriberNotFound  = "SUBSCRIBER_NOT_FOUND"
    case billAlreadyPaid     = "BILL_ALREADY_PAID"
    case inquiryExpired      = "INQUIRY_EXPIRED"
    case insufficientBalance = "INSUFFICIENT_BALANCE"
    case serviceUnavailable  = "SERVICE_UNAVAILABLE"
    case rateLimited         = "RATE_LIMITED"
    case unknown             = "UNKNOWN"

    /// Used only when the server sent no message.
    var fallbackText: String {
        switch self {
        case .validation:
            return String(localized: "Please check the information you entered.")
        case .unauthorized:
            return String(localized: "You are not authorized to perform this action.")
        case .subscriberNotFound:
            return String(localized: "No bill was found for this subscriber number.")
        case .billAlreadyPaid:
            return String(localized: "There is nothing due on this account.")
        case .inquiryExpired:
            return String(localized: "This inquiry has expired. Please start again.")
        case .insufficientBalance:
            return String(localized: "Insufficient balance to complete this payment.")
        case .serviceUnavailable:
            return String(localized: "This service is currently unavailable. Please try again later.")
        case .rateLimited:
            return String(localized: "Too many attempts. Please wait a minute and try again.")
        case .unknown:
            return String(localized: "Something went wrong. Please try again.")
        }
    }
}


// MARK: - NetworkError

enum NetworkError: LocalizedError, Equatable {

    // Transport (the request never got a server answer)
    case invalidURL
    case noConnectivity
    case timeout
    case cancelled

    // Anything the backend answered with an error
    case api(code: APIErrorCode, message: String?, field: String?)

    // Backend answered with no usable envelope (e.g. an HTML error page)
    case server(statusCode: Int)
    case client(statusCode: Int)

    // Local
    case decoding(String)
    case unknown(String)
    

    // MARK: Mapping from the server

    static func from(statusCode: Int, envelope: APIErrorEnvelope?) -> NetworkError {

        // 1. The server told us what went wrong: keep its code AND its message.
        if let body = envelope?.error {
            return .api(code: APIErrorCode(rawValue: body.code) ?? .unknown,
                        message: serverMessage(body),
                        field: body.field)
        }

        // 2. No envelope: fall back on the HTTP status.
        switch statusCode {
        case 400:       return .api(code: .validation, message: nil, field: nil)
        case 401:       return .api(code: .unauthorized, message: nil, field: nil)
        case 402:       return .api(code: .insufficientBalance, message: nil, field: nil)
        case 404:       return .api(code: .subscriberNotFound, message: nil, field: nil)
        case 410:       return .api(code: .inquiryExpired, message: nil, field: nil)
        case 429:       return .api(code: .rateLimited, message: nil, field: nil)
        case 503:       return .api(code: .serviceUnavailable, message: nil, field: nil)
        case 500...599: return .server(statusCode: statusCode)
        default:        return .client(statusCode: statusCode)
        }
    }

    static func from(urlError error: URLError) -> NetworkError {
        switch error.code {
        case .notConnectedToInternet, .networkConnectionLost, .dataNotAllowed,
             .cannotFindHost, .cannotConnectToHost, .dnsLookupFailed, .internationalRoamingOff:
            return .noConnectivity
        case .timedOut:
            return .timeout
        case .badURL, .unsupportedURL:
            return .invalidURL
        case .cancelled:
            return .cancelled
        default:
            return .unknown(error.localizedDescription)
        }
    }
    
    private static func serverMessage(_ body: APIErrorEnvelope.Body) -> String? {
        let language = UserDefaults.standard.string(forKey: "selectedLanguage") ?? "en"
        if language.hasPrefix("ar"), let ar = body.messageAr, !ar.isEmpty { return ar }
        return body.messageEn ?? body.messageAr
    }

    var errorDescription: String? {
        switch self {
        case .api(let code, let message, _):
            return message ?? code.fallbackText      // backend message first
        case .invalidURL:
            return String(localized: "The request URL is invalid.")
        case .noConnectivity:
            return String(localized: "No internet connection. Please check your network.")
        case .timeout:
            return String(localized: "The request timed out. Please try again.")
        case .cancelled:
            return String(localized: "The request was cancelled.")
        case .server(let statusCode):
            return String(localized: "Server error (\(statusCode)). Please try again later.")
        case .client(let statusCode):
            return String(localized: "Request error (\(statusCode)). Please check and try again.")
        case .decoding:
            return String(localized: "Failed to process the server response.")
        case .unknown(let message):
            return String(localized: "Something went wrong: \(message)")
        }
    }
}
