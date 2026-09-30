//
//  FeesInquiryViewModel.swift
//  MomknPay
//
//  Created by Mohamed Adel on 29/09/2026.
//


import Foundation

@MainActor
@Observable
class FeesInquiryViewModel {

    var displayText = ""

    let maxDigits = 10

    var rawDigits: String {
        displayText.filter(\.isNumber)
    }

    var isComplete: Bool {
        rawDigits.count == maxDigits
    }

    func formatSubscriberNumber() {
        let digits = String(displayText.filter(\.isNumber).prefix(maxDigits))

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
    }
}
