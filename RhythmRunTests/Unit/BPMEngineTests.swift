import XCTest
@testable import RhythmRun

final class BPMEngineTests: XCTestCase {
    var sut: BPMEngine!

    override func setUp() {
        super.setUp()
        sut = BPMEngine()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func test_초기_BPM은_0이다() {
        XCTAssertEqual(sut.currentBPM, 0)
    }

    func test_걸음이_쌓이면_BPM이_계산된다() {
        let now = Date()
        // 10초 안에 27번 → 약 162 BPM
        for i in 0..<27 {
            sut.recordStep(at: now.addingTimeInterval(Double(i) * (10.0 / 27.0)))
        }
        XCTAssertGreaterThan(sut.currentBPM, 0)
    }

    func test_유효범위_밖의_BPM은_이전값_유지() {
        // 200 BPM 초과 (노이즈) 시 currentBPM 변경 없음
        let baseline = sut.currentBPM
        let now = Date()
        // 1초에 5번 → 300 BPM (유효범위 초과)
        for i in 0..<5 {
            sut.recordStep(at: now.addingTimeInterval(Double(i) * 0.2))
        }
        XCTAssertEqual(sut.currentBPM, baseline)
    }

    func test_리셋후_BPM은_0이다() {
        sut.recordStep(at: Date())
        sut.reset()
        XCTAssertEqual(sut.currentBPM, 0)
    }
}
