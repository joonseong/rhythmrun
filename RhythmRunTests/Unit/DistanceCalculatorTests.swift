import XCTest
@testable import RhythmRun

final class DistanceCalculatorTests: XCTestCase {
    func test_140BPM_이하_걷기_보폭계수() {
        let stride = DistanceCalculator.strideLength(heightCM: 170, bpm: 140)
        XCTAssertEqual(stride, 170 * 0.413, accuracy: 0.001)
    }

    func test_141BPM_이상_러닝_보폭계수() {
        let stride = DistanceCalculator.strideLength(heightCM: 170, bpm: 141)
        XCTAssertEqual(stride, 170 * 0.46, accuracy: 0.001)
    }

    func test_거리_계산() {
        // 1000보, 신장 170cm, 160BPM → 러닝 계수
        let dist = DistanceCalculator.distanceMeters(steps: 1000, heightCM: 170, bpm: 160)
        let expected = 1000.0 * (170 * 0.46) / 100
        XCTAssertEqual(dist, expected, accuracy: 0.001)
    }
}
