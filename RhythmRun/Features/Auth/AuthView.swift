import SwiftUI

struct AuthView: View {
    let onLogin: () -> Void

    var body: some View {
        ZStack {
            Color.rrVoid.ignoresSafeArea()

            VStack(spacing: 32) {
                Text("🏃 RhythmRun")
                    .font(.rrDisplay)
                    .foregroundColor(.rrWhite)

                Text("달릴 때마다 게임이 된다")
                    .font(.rrBody)
                    .foregroundColor(.rrMuted)

                VStack(spacing: 16) {
                    RRPrimaryButton(title: "이메일로 시작하기", action: onLogin)
                    RRSecondaryButton(title: "Apple로 로그인", action: onLogin)
                    RRSecondaryButton(title: "Google로 로그인", action: onLogin)
                }
            }
            .padding(32)
        }
    }
}
