import SwiftUI

extension Color {
    // 배경 계층
    static let rrVoid       = Color(hex: "#000000")
    static let rrDeepTeal   = Color(hex: "#02090A")
    static let rrDarkForest = Color(hex: "#061A1C")
    static let rrForest     = Color(hex: "#102620")

    // 텍스트
    static let rrWhite      = Color.white
    static let rrMuted      = Color(hex: "#A1A1AA")
    static let rrShade50    = Color(hex: "#71717A")

    // 액센트
    static let rrNeonGreen  = Color(hex: "#36F4A4")

    // 보더
    static let rrCardBorder = Color(hex: "#1E2C31")

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
