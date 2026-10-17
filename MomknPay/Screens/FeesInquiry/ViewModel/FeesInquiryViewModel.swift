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
    let lengthRange: ClosedRange<Int>

    var displayText = ""
    var inquiry: InquiryResponse?
 
    private(set) var state: InquiryState = .idle
 
    init(service: Service) {
        self.service = service
        self.lengthRange = service.inputLengthRange
    }
    
    var maxDigits: Int { lengthRange.upperBound }

    var rawDigits: String {
        displayText.filter { $0.isASCII && $0.isNumber }
    }

    var isValid: Bool {
        service.isValidInput(rawDigits)
    }

    /// placeholder.
    var hint: String {
        lengthRange.lowerBound == lengthRange.upperBound
            ? String(localized: "\(lengthRange.upperBound) digits")
            : String(localized: "\(lengthRange.lowerBound) to \(lengthRange.upperBound) digits")
    }
    
    var helperText: String {
        let digits = lengthRange.lowerBound == lengthRange.upperBound
            ? "\(lengthRange.upperBound)"
            : "\(lengthRange.lowerBound) to \(lengthRange.upperBound)"

        return String(localized: "Enter your \(service.inputLabel.lowercased()), \(digits) digits, numbers only")
    }

    var validationMessage: String {
        String(localized: "Enter a valid \(service.inputLabel.lowercased()) (\(hint))")
    }

    var isLoading: Bool {
        state == .loading
    }

    var canSubmit: Bool {
        rawDigits.count >= lengthRange.lowerBound && !isLoading
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
            if index > 0 && index % 4 == 0 {
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

    func validate() -> Bool {
        guard isValid else {
            state = .failed(.unknown(validationMessage))
            return false
        }
        return true
    }


    @MainActor
    func submit() async {
        guard canSubmit, isValid else { return }

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
