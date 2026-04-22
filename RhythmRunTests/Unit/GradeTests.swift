import XCTest
@testable import RhythmRun

final class GradeTests: XCTestCase {
    func test_90퍼센트_이상_S등급() {
        XCTAssertEqual(RunSession.Grade.from(accuracy: 0.90), .s)
        XCTAssertEqual(RunSession.Grade.from(accuracy: 1.00), .s)
    }

    func test_75퍼센트_이상_A등급() {
        XCTAssertEqual(RunSession.Grade.from(accuracy: 0.75), .a)
        XCTAssertEqual(RunSession.Grade.from(accuracy: 0.89), .a)
    }

    func test_60퍼센트_이상_B등급() {
        XCTAssertEqual(RunSession.Grade.from(accuracy: 0.60), .b)
        XCTAssertEqual(RunSession.Grade.from(accuracy: 0.74), .b)
    }

    func test_60퍼센트_미만_C등급() {
        XCTAssertEqual(RunSession.Grade.from(accuracy: 0.59), .c)
        XCTAssertEqual(RunSession.Grade.from(accuracy: 0.00), .c)
    }
}
