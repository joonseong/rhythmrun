import SwiftUI

struct OnboardingView: View {
    let onComplete: () -> Void
    @State private var heightText = ""
    @State private var weightText = ""

    var body: some View {
        ZStack {
            Color.rrVoid.ignoresSafeArea()

            VStack(spacing: 32) {
                Text("정확한 운동 데이터를 위해\n신체 정보를 입력해주세요")
                    .font(.rrTitle)
                    .foregroundColor(.rrWhite)
                    .multilineTextAlignment(.center)

                VStack(spacing: 16) {
                    RRTextField(placeholder: "신장 (cm)", text: $heightText)
                    RRTextField(placeholder: "체중 (kg)", text: $weightText)
                }

                RRPrimaryButton(title: "다음", action: onComplete)
            }
            .padding(32)
        }
    }
}

struct RRTextField: View {
    let placeholder: String
    @Binding var text: String

    var body: some View {
        TextField(placeholder, text: $text)
            .foregroundColor(.rrWhite)
            .padding(14)
            .background(Color.rrDarkForest)
            .cornerRadius(8)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.rrCardBorder, lineWidth: 1))
    }
}
