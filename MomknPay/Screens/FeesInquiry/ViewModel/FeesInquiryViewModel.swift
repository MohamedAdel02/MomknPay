//
//  FeesInquiryViewModel.swift
//  MomknPay
//
//  Created by Mohamed Adel on 29/09/2026.
//

import Foundation
 
@Observable
class FeesInquiryViewModel {
 
    enum InquiryState: Equatable {
        case idle
        case loading
        case failed(NetworkError)
    }
 
    private static let useMockData = true
 
    let service: Service
    let maxDigits = 10
 
    var displayText = ""
    var inquiry: InquiryResponse?
 
    private(set) var state: InquiryState = .idle
 
    init(service: Service) {
        self.service = service
    }
    // MARK: Derived state
 
    var rawDigits: String {
        displayText.filter(\.isNumber)
    }
 
    var isComplete: Bool {
        rawDigits.count == maxDigits
    }
 
    var isLoading: Bool {
        state == .loading
    }
 
    var canSubmit: Bool {
        isComplete && !isLoading
    }
 
    var errorMessage: String? {
        if case .failed(let error) = state {
            return error.errorDescription
        }
        return nil
    }
 
    private var mockInquiry: InquiryResponse {
        InquiryResponse(
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
  
    func formatSubscriberNumber() {
        let digits = String(rawDigits.prefix(maxDigits))
 
        var result = ""
        for (index, character) in digits.enumerated() {
            if index == 4 || index == 8 {
                result += " "
            }
            result.append(character)
        }
 
        if result != displayText {
            displayText = result
        }
 
        // Typing again clears a previous error.
        if case .failed = state {
            state = .idle
        }
    }
 
    @MainActor
    func submit() async {
        guard canSubmit else { return }
 
        state = .loading
 
        do {
            if Self.useMockData {
                try await Task.sleep(for: .seconds(1))
                inquiry = mockInquiry
            } else {
                let body = InquiryRequest(serviceId: service.id, payload: rawDigits)
                let request = try Endpoint.inquiry(body).asHTTPRequest()
                inquiry = try await NetworkManager.shared.send(request, as: InquiryResponse.self)
            }
            state = .idle
        } catch let error as NetworkError {
            state = error == .cancelled ? .idle : .failed(error)
        } catch let error as URLError {
            state = .failed(.from(urlError: error))
        } catch {
            state = .failed(.unknown(error.localizedDescription))
        }
    }
}
 
