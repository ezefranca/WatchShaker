import XCTest
@testable import WatchShaker

#if os(watchOS)
final class WatchShakerTests: XCTestCase {
    func testInstance() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        let sut = WatchShaker(shakeSensibility: .shakeSensibilityHard, delay: 2)
        sut.start()
        XCTAssertNotNil(sut)
        XCTAssertFalse(sut.isShakerAvailable)
        sut.isShakerAvailable = true
        XCTAssertTrue(sut.isShakerAvailable)
    }
}
#endif
