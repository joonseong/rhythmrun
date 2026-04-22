import Foundation

enum DistanceCalculator {
    static func strideLength(heightCM: Double, bpm: Int) -> Double {
        bpm <= 140 ? heightCM * 0.413 : heightCM * 0.46
    }

    static func distanceMeters(steps: Int, heightCM: Double, bpm: Int) -> Double {
        let strideCM = strideLength(heightCM: heightCM, bpm: bpm)
        return Double(steps) * strideCM / 100
    }
}
