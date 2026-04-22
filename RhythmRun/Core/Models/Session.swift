import Foundation

struct RunSession: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    let difficulty: Difficulty
    let durationSeconds: Int
    let totalScore: Int
    let maxCombo: Int
    let grade: Grade
    let avgBPM: Int
    let bpmTimeline: [BPMSample]

    enum Difficulty: String, Codable {
        case walk, run, sprint
    }

    enum Grade: String, Codable {
        case s = "S"
        case a = "A"
        case b = "B"
        case c = "C"

        static func from(accuracy: Double) -> Grade {
            switch accuracy {
            case 0.90...: return .s
            case 0.75...: return .a
            case 0.60...: return .b
            default:      return .c
            }
        }
    }
}

struct BPMSample: Codable {
    let offsetSeconds: Int
    let bpm: Int
}
