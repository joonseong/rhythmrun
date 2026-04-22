import SwiftUI

struct RRPrimaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.rrBody)
                .foregroundColor(.rrVoid)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
        }
        .background(Color.rrWhite)
        .clipShape(Capsule())
    }
}

struct RRSecondaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.rrBody)
                .foregroundColor(.rrWhite)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
        }
        .overlay(Capsule().stroke(Color.rrWhite, lineWidth: 2))
        .clipShape(Capsule())
    }
}
