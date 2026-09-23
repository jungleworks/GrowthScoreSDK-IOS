//
//  AppReviewManager.swift
//  GrowthScore
//

import Foundation
import StoreKit
import UIKit

/// Bridges `AppReviewGate` to iOS: persists the gate's state in UserDefaults and
/// asks StoreKit for the review prompt when the gate allows it.
enum AppReviewManager {

    private static let dueAtKey = "growthscore_app_review_due_at"
    private static let shownKey = "growthscore_app_review_shown"
    private static let secondsPerMinute: TimeInterval = 60

    // One shared gate, so its lock actually guards concurrent checks from two screens.
    private static let gate = AppReviewGate(store: DefaultsStore())

    /// Arms the prompt when a promoter score comes back from a successful submit.
    static func onScoreSubmitted(score: Int) {
        let config = GrowthConfig.shared
        guard config.appReviewEnabled else { return }

        let delayMinutes = max(config.appReviewDelayMinutes, 0)
        gate.arm(
            score: score,
            minScore: config.appReviewMinScore,
            delay: TimeInterval(delayMinutes) * secondsPerMinute
        )
    }

    /// StoreKit decides whether a sheet is actually drawn, and never reports back
    /// whether the user reviewed. `true` here only means the request was made.
    static func checkAndShow(in scene: UIWindowScene?, completion: ((Bool) -> Void)?) {
        // StoreKit's review APIs and scene state are main-actor bound.
        Task { @MainActor in
            guard GrowthConfig.shared.appReviewEnabled else {
                completion?(false)
                return
            }
            // Check the scene before consuming, so a missing scene doesn't burn the one-time prompt.
            guard let scene, scene.activationState == .foregroundActive else {
                completion?(false)
                return
            }
            guard gate.consume() else {
                completion?(false)
                return
            }

            if #available(iOS 16.0, *) {
                AppStore.requestReview(in: scene)
            } else {
                SKStoreReviewController.requestReview(in: scene)
            }
            completion?(true)
        }
    }

    static func reset() {
        gate.reset()
    }

    private final class DefaultsStore: AppReviewStore {

        private let defaults = UserDefaults.standard

        var dueAt: TimeInterval {
            get { defaults.double(forKey: AppReviewManager.dueAtKey) }
            set { defaults.set(newValue, forKey: AppReviewManager.dueAtKey) }
        }

        var shown: Bool {
            get { defaults.bool(forKey: AppReviewManager.shownKey) }
            set { defaults.set(newValue, forKey: AppReviewManager.shownKey) }
        }
    }
}
