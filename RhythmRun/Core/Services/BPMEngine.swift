import Foundation

protocol BPMEngineProtocol {
    var currentBPM: Int { get }
    func recordStep(at timestamp: Date)
    func reset()
}

final class BPMEngine: BPMEngineProtocol {
    private let windowSeconds: Double = 10
    private let validRange: ClosedRange<Int> = 60...200
    private var stepTimestamps: [Date] = []

    private(set) var currentBPM: Int = 0

    func recordStep(at timestamp: Date = .now) {
        let cutoff = timestamp.addingTimeInterval(-windowSeconds)
        stepTimestamps = stepTimestamps.filter { $0 > cutoff }
        stepTimestamps.append(timestamp)

        let raw = Int(Double(stepTimestamps.count) / windowSeconds * 60)
        currentBPM = validRange.contains(raw) ? raw : currentBPM
    }

    func reset() {
        stepTimestamps.removeAll()
        currentBPM = 0
    }
}
