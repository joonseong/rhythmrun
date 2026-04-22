import Foundation

struct UserProfile: Codable {
    var nickname: String
    var heightCM: Double
    var weightKG: Double
    var goalBPM: Int
    var strideCM: Double?

    static let defaultHeightCM: Double = 170
    static let defaultWeightKG: Double = 65

    var effectiveStrideCM: Double {
        strideCM ?? heightCM * 0.46
    }
}
