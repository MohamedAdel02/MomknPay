//
//  Service+Extensions.swift
//  MomknPay
//
//  Created by Mohamed Adel on 17/10/2026.
//

import Foundation

extension Service {

    var inputLengthRange: ClosedRange<Int> {
        let fallback = 1...15

        var pattern = Substring(inputPattern)
        if pattern.hasPrefix("^") { pattern.removeFirst() }
        if pattern.hasSuffix("$") { pattern.removeLast() }

        var minTotal = 0
        var maxTotal = 0
        var i = pattern.startIndex

        while i < pattern.endIndex {

            var next: Substring.Index
            if pattern[i] == "[" {
                guard let close = pattern[i...].firstIndex(of: "]") else { return fallback }
                next = pattern.index(after: close)
            } else {
                next = pattern.index(after: i)
            }

            var low = 1
            var high = 1

            if next < pattern.endIndex, pattern[next] == "{" {
                guard let close = pattern[next...].firstIndex(of: "}") else { return fallback }
                let inside = pattern[pattern.index(after: next)..<close]
                let parts = inside.split(separator: ",", omittingEmptySubsequences: false)
                guard let first = parts.first.flatMap({ Int($0) }) else { return fallback }
                low = first
                if parts.count == 2 {
                    guard let second = Int(parts[1]) else { return fallback } // "{8,}" is unbounded
                    high = second
                } else {
                    high = first
                }
                next = pattern.index(after: close)
            }

            minTotal += low
            maxTotal += high
            i = next
        }

        return minTotal > 0 && maxTotal >= minTotal ? minTotal...maxTotal : fallback
    }

    func isValidInput(_ digits: String) -> Bool {
        digits.range(of: inputPattern, options: .regularExpression) != nil
    }
}
