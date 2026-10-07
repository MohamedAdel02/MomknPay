//
//  BillDetailsViewModel.swift
//  MomknPay
//
//  Created by Mohamed Adel on 25/09/2026.
//

import Foundation

@Observable
class BillDetailsViewModel {

    let inquiry: InquiryResponse
    let service: Service
    let subscriberNumber: String

    private static let quoteDuration: TimeInterval? = 5 * 60

    private let deadline: Date
    private(set) var remaining: Int
    private var timerTask: Task<Void, Never>?

    init(inquiry: InquiryResponse, service: Service, subscriberNumber: String, remaining: Int = 10) {
        self.inquiry = inquiry
        self.service = service
        self.subscriberNumber = subscriberNumber

        if let duration = Self.quoteDuration {
            self.deadline = Date().addingTimeInterval(duration)
        } else {
            self.deadline = inquiry.expiresAt
        }
        self.remaining = remaining
    }

    var isExpired: Bool { remaining == 0 }

    var formattedCountdown: String {
        String(format: "%02d:%02d", remaining / 60, remaining % 60)
    }

    var currency: String { inquiry.currency }

    var amountDueText: String { Self.money(inquiry.amountDue) }
    var serviceFeeText: String { Self.money(inquiry.serviceFee) }
    var vatText: String { Self.money(inquiry.vat) }
    var totalText: String { Self.money(inquiry.total) }

    /// "2026-08" -> "August 2026"
    var billMonthText: String {
        let parser = DateFormatter()
        parser.locale = Locale(identifier: "en_US_POSIX")
        parser.dateFormat = "yyyy-MM"
        guard let date = parser.date(from: inquiry.billMonth) else { return inquiry.billMonth }
        return date.formatted(.dateTime.month(.wide).year())
    }

    func onAppear() {
        startTimer()
    }

    func onDisappear() {
        stopTimer()
    }

    private func startTimer() {
        guard timerTask == nil, remaining > 0 else { return }
        timerTask = Task { [weak self] in
            while let self, !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { return }
                self.tick()
            }
        }
    }

    private func stopTimer() {
        timerTask?.cancel()
        timerTask = nil
    }

    private func tick() {
        guard remaining > 0 else {
            stopTimer()
            return
        }
        remaining -= 1
        if remaining == 0 {
            stopTimer()
        }
    }
    
    private static func money(_ piastres: Int) -> String {
        (Decimal(piastres) / 100).formatted(.number.precision(.fractionLength(2)))
    }
    
}
