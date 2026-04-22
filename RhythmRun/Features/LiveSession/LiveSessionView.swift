import SwiftUI

struct LiveSessionView: View {
    let config: SessionConfig
    @StateObject private var vm: LiveSessionViewModel

    init(config: SessionConfig) {
        self.config = config
        _vm = StateObject(wrappedValue: LiveSessionViewModel(config: config))
    }

    var body: some View {
        ZStack {
            Color.rrVoid.ignoresSafeArea()

            VStack(spacing: 24) {
                Text("\(vm.currentBPM) BPM")
                    .font(.rrDisplay)
                    .foregroundColor(.rrNeonGreen)

                Text("콤보: \(vm.combo)")
                    .font(.rrTitle)
                    .foregroundColor(.rrWhite)

                Text("스코어: \(vm.score)")
                    .font(.rrBody)
                    .foregroundColor(.rrMuted)

                Spacer()

                RRSecondaryButton(title: "✕ 종료") {
                    vm.endSession()
                }
            }
            .padding(24)
        }
        .onAppear { vm.startSession() }
        .onDisappear { vm.endSession() }
        .navigationBarHidden(true)
    }
}
