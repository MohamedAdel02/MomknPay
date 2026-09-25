//
//  BillDetailsViewModel.swift
//  MomknPay
//
//  Created by Mohamed Adel on 25/09/2026.
//

import Foundation

@Observable
final class BillDetailsViewModel {

    private(set) var remaining: Int
    private var timerTask: Task<Void, Never>?

    var formattedCountdown: String {
        String(format: "%02d:%02d", remaining / 60, remaining % 60)
    }

    init(remaining: Int = 272) {
        self.remaining = remaining
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
}
