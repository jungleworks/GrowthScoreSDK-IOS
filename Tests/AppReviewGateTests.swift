import XCTest
@testable import GrowthScore

final class AppReviewGateTests: XCTestCase {

    private final class FakeStore: AppReviewStore {
        var dueAt: TimeInterval
        var shown: Bool

        init(dueAt: TimeInterval = 0, shown: Bool = false) {
            self.dueAt = dueAt
            self.shown = shown
        }
    }

    private func gate(at now: TimeInterval, store: AppReviewStore) -> AppReviewGate {
        AppReviewGate(store: store, now: { now })
    }

    func testArmingWithAQualifyingScoreSchedulesThePromptAfterTheDelay() {
        let store = FakeStore()

        gate(at: 5_000, store: store).arm(score: 9, minScore: 9, delay: 1_000)

        XCTAssertEqual(store.dueAt, 6_000)
    }

    func testAScoreBelowTheMinimumDoesNotArmThePrompt() {
        let store = FakeStore()

        gate(at: 5_000, store: store).arm(score: 8, minScore: 9, delay: 1_000)

        XCTAssertEqual(store.dueAt, 0)
    }

    func testAQualifyingScoreDoesNotReArmOnceThePromptHasBeenShown() {
        let store = FakeStore(shown: true)

        gate(at: 5_000, store: store).arm(score: 10, minScore: 9, delay: 1_000)

        XCTAssertEqual(store.dueAt, 0)
    }

    func testASecondQualifyingScoreKeepsTheOriginalDueTime() {
        let store = FakeStore(dueAt: 6_000)

        gate(at: 20_000, store: store).arm(score: 10, minScore: 9, delay: 1_000)

        XCTAssertEqual(store.dueAt, 6_000)
    }

    func testNothingIsShownWhenNoQualifyingScoreHasBeenSubmitted() {
        XCTAssertFalse(gate(at: 9_999, store: FakeStore()).consume())
    }

    func testNothingIsShownBeforeTheDelayHasElapsed() {
        XCTAssertFalse(gate(at: 5_999, store: FakeStore(dueAt: 6_000)).consume())
    }

    func testThePromptIsShownOnceTheDelayHasElapsed() {
        XCTAssertTrue(gate(at: 6_000, store: FakeStore(dueAt: 6_000)).consume())
    }

    func testThePromptIsShownOnTheFirstCheckAfterTheDelayElapses() {
        XCTAssertTrue(gate(at: 500_000, store: FakeStore(dueAt: 6_000)).consume())
    }

    func testThePromptIsNeverShownASecondTime() {
        let subject = gate(at: 500_000, store: FakeStore(dueAt: 6_000))

        _ = subject.consume()

        XCTAssertFalse(subject.consume())
    }

    func testResettingClearsTheStateSoALaterScoreCanArmAgain() {
        let store = FakeStore(dueAt: 6_000, shown: true)
        let subject = gate(at: 20_000, store: store)

        subject.reset()
        subject.arm(score: 10, minScore: 9, delay: 1_000)

        XCTAssertEqual(store.dueAt, 21_000)
    }
}
