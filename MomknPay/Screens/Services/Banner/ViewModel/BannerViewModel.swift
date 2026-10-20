//
//  BannerViewModel.swift
//  MomknPay
//
//  Created by Mohamed Adel on 20/10/2026.
//

import SwiftUI

@Observable
class BannerViewModel {

    let banners: [Banner]
    let autoScrollInterval: TimeInterval = 5
    let repeats = 10

    var currentID: Int?
    var lastIndex: Int

    private var hasPositioned = false
    private var isTouching = false
    private var lastInteraction = Date.distantPast
    private var recentreTask: Task<Void, Never>?

    init(banners: [Banner] = Banner.all,) {
        
        self.banners = banners

        let start = banners.count * (repeats / 2)
        self.currentID = start
        self.lastIndex = start
    }


    var isEmpty: Bool { banners.isEmpty }

    var total: Int { banners.count * repeats }
    var middle: Int { banners.count * (repeats / 2) }

    var currentPage: Int {
        guard !banners.isEmpty else { return 0 }
        return lastIndex % banners.count
    }

    func banner(at index: Int) -> Banner {
        banners[index % banners.count]
    }

    func positionChanged(_ newValue: Int?) {
        guard let newValue else { return }
        lastIndex = newValue
        scheduleRecentre()
    }

    func touchBegan() {
        isTouching = true
        lastInteraction = Date()
    }

    func touchEnded() {
        isTouching = false
        lastInteraction = Date()
        scheduleRecentre()
    }

    // MARK: - Auto scroll

    /// Moves to the next banner every `autoScrollInterval` seconds until the task is cancelled.
    /// - Parameter step: -1 moves the banners visually left to right in LTR; pass +1 for RTL.
    func runAutoScroll(step: Int) async {
        guard !banners.isEmpty else { return }

        while !Task.isCancelled {
            try? await Task.sleep(for: .seconds(autoScrollInterval))
            if Task.isCancelled { break }
            advance(step: step)
        }
    }

    private func advance(step: Int) {

        guard !isTouching,
              Date().timeIntervalSince(lastInteraction) >= autoScrollInterval - 0.5 else { return }

        recentreIfNeeded()

        withAnimation(.easeInOut(duration: 0.5)) {
            currentID = lastIndex + step
        }
    }

    // MARK: - Infinite loop

    /// Waits until scrolling settles, then recentres if we drifted close to an end.
    private func scheduleRecentre() {
        recentreTask?.cancel()
        recentreTask = Task { @MainActor [weak self] in
            try? await Task.sleep(for: .milliseconds(400))
            guard !Task.isCancelled, let self, !self.isTouching else { return }
            self.recentreIfNeeded()
        }
    }

    /// Jumps (without animation) to the same banner in the middle copy.
    /// The visible content is identical, so the user doesn't notice.
    private func recentreIfNeeded() {
        guard !banners.isEmpty else { return }

        let margin = banners.count * 2
        guard lastIndex < margin || lastIndex >= total - margin else { return }

        let target = middle + (lastIndex % banners.count)

        var transaction = Transaction(animation: nil)
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            currentID = target
        }
        lastIndex = target
    }
}
