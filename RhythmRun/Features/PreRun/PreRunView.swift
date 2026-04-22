import SwiftUI

struct PreRunView: View {
    @StateObject private var vm = PreRunViewModel()
    @State private var navigateToSession = false

    var body: some View {
        ZStack {
            Color.rrVoid.ignoresSafeArea()

            VStack(spacing: 32) {
                Text("오늘 어떻게 달릴까요?")
                    .font(.rrTitle)
                    .foregroundColor(.rrWhite)

                RRPrimaryButton(title: "🏃 출발!") {
                    navigateToSession = true
                }
            }
            .padding(24)
        }
        .navigationDestination(isPresented: $navigateToSession) {
            LiveSessionView(config: vm.sessionConfig)
        }
    }
}
