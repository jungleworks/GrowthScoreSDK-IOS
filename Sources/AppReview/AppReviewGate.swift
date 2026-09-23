//
//  AppReviewGate.swift
//  GrowthScore
//

import Foundation

/// Persisted state for the in-app review prompt. Kept behind a protocol so the
/// gating rules can be exercised without UserDefaults.
protocol AppReviewStore: AnyObject {
    var dueAt: TimeInterval { get set }
    var shown: Bool { get set }
}

/// Decides whether the App Store in-app review prompt should be shown.
///
/// Holds no UIKit or StoreKit types, so every rule here is covered by plain unit tests.
final class AppReviewGate {

    private static let notArmed: TimeInterval = 0

    private let store: AppReviewStore
    private let now: () -> TimeInterval
    private let lock = NSLock()

    init(
        store: AppReviewStore,
        now: @escaping () -> TimeInterval = { Date().timeIntervalSince1970 }
    ) {
        self.store = store
        self.now = now
    }

    func arm(score: Int, minScore: Int, delay: TimeInterval) {
        lock.lock()
        defer { lock.unlock() }

        guard score >= minScore else { return }
        guard !store.shown else { return }
        // Keep the countdown from the first qualifying score; a later one must not push it out.
        guard store.dueAt == Self.notArmed else { return }

        store.dueAt = now() + delay
    }

    /// Returns true at most once, on the first call after the delay has elapsed.
    /// Claiming and marking happen together so two screens becoming active at the
    /// same moment cannot both launch the flow.
    func consume() -> Bool {
        lock.lock()
        defer { lock.unlock() }

        guard !store.shown else { return false }
        guard store.dueAt != Self.notArmed else { return false }
        guard now() >= store.dueAt else { return false }

        store.shown = true
        store.dueAt = Self.notArmed
        return true
    }

    func reset() {
        lock.lock()
        defer { lock.unlock() }

        store.shown = false
        store.dueAt = Self.notArmed
    }
}
