//
//  NetworkManager.swift
//  MomknPay
//
//

import Foundation

class NetworkManager {

    static let shared = NetworkManager()

    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared, decoder: JSONDecoder = .api) {
        self.session = session
        self.decoder = decoder
    }

    func send<T: Decodable>(_ request: HTTPRequest, as type: T.Type) async throws -> T {
        let data = try await execute(request)
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decoding(String(describing: error))
        }
    }


    private func execute(_ request: HTTPRequest) async throws -> Data {
        let urlRequest = buildURLRequest(request)

        do {
            let (data, response) = try await session.data(for: urlRequest)

            guard let http = response as? HTTPURLResponse else {
                throw NetworkError.unknown("Non-HTTP response")
            }

            if (200...299).contains(http.statusCode) {
                return data
            }

            let envelope = try? decoder.decode(APIErrorEnvelope.self, from: data)
            throw NetworkError.from(statusCode: http.statusCode, envelope: envelope)

        } catch let error as NetworkError {
            throw error
        } catch let error as URLError {
            throw NetworkError.from(urlError: error)
        } catch is CancellationError {
            throw NetworkError.cancelled
        } catch {
            throw NetworkError.unknown(error.localizedDescription)
        }
    }

    private func buildURLRequest(_ request: HTTPRequest) -> URLRequest {
        var urlRequest = URLRequest(url: request.url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.httpBody = request.body

        var headers = [
            "Accept": "application/json",
            "X-Request-Id": UUID().uuidString,
            "X-Client-Platform": "ios",
            "X-Client-Version": "1.0"
        ]
        
        if request.body != nil { headers["Content-Type"] = "application/json" }
        headers.merge(request.headers) { _, custom in custom }

        urlRequest.allHTTPHeaderFields = headers
        return urlRequest
    }
}
