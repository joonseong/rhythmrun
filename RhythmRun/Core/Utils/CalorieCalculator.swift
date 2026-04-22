import Foundation

enum CalorieCalculator {
    static func met(for bpm: Int) -> Double {
        switch bpm {
        case ...140: return 3.5
        case 141...160: return 7.0
        default: return 9.8
        }
    }

    static func kcal(bpm: Int, weightKG: Double, durationSeconds: Double) -> Double {
        met(for: bpm) * weightKG * (durationSeconds / 3600)
    }
}
