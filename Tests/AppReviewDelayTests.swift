import XCTest
@testable import GrowthScore

/// The delay is configurable in minutes or hours. Both names read and write the
/// same stored value, so a host app can never set one and have the other disagree.
final class AppReviewDelayTests: XCTestCase {

    override func tearDown() {
        GrowthConfig.shared.appReviewDelayMinutes = 48 * 60
        super.tearDown()
    }

    func testTheDelayDefaultsTo48Hours() {
        XCTAssertEqual(GrowthConfig.shared.appReviewDelayHours, 48)
        XCTAssertEqual(GrowthConfig.shared.appReviewDelayMinutes, 48 * 60)
    }

    func testSettingHoursIsReadableAsMinutes() {
        GrowthConfig.shared.appReviewDelayHours = 24

        XCTAssertEqual(GrowthConfig.shared.appReviewDelayMinutes, 1_440)
    }

    func testSettingMinutesIsReadableAsHours() {
        GrowthConfig.shared.appReviewDelayMinutes = 120

        XCTAssertEqual(GrowthConfig.shared.appReviewDelayHours, 2)
    }

    func testASubHourDelaySurvivesBeingWritten() {
        GrowthConfig.shared.appReviewDelayMinutes = 1

        XCTAssertEqual(GrowthConfig.shared.appReviewDelayMinutes, 1)
    }
}
