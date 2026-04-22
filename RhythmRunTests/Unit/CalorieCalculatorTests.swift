import XCTest
@testable import RhythmRun

final class CalorieCalculatorTests: XCTestCase {
    func test_BPM_140이하_MET_3점5() {
        XCTAssertEqual(CalorieCalculator.met(for: 140), 3.5)
    }

    func test_BPM_141_160_MET_7() {
        XCTAssertEqual(CalorieCalculator.met(for: 160), 7.0)
        XCTAssertEqual(CalorieCalculator.met(for: 141), 7.0)
    }

    func test_BPM_161이상_MET_9점8() {
        XCTAssertEqual(CalorieCalculator.met(for: 161), 9.8)
    }

    func test_칼로리_계산_30분_65kg_160BPM() {
        let kcal = CalorieCalculator.kcal(bpm: 160, weightKG: 65, durationSeconds: 1800)
        let expected = 7.0 * 65 * (1800.0 / 3600)
        XCTAssertEqual(kcal, expected, accuracy: 0.001)
    }
}
