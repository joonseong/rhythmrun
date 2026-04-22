import SwiftUI

struct HomeView: View {
    @StateObject private var vm = HomeViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.rrVoid.ignoresSafeArea()

                VStack(alignment: .leading, spacing: 24) {
                    Text("안녕하세요, \(vm.nickname)님")
                        .font(.rrTitle)
                        .foregroundColor(.rrWhite)

                    NavigationLink(destination: PreRunView()) {
                        RRPrimaryButton(title: "🎵 리듬 러닝 시작") {}
                    }

                    Spacer()
                }
                .padding(24)
            }
            .navigationBarHidden(true)
        }
    }
}
