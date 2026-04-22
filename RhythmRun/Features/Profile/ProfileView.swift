import SwiftUI

struct ProfileView: View {
    @StateObject private var vm = ProfileViewModel()

    var body: some View {
        ZStack {
            Color.rrVoid.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 24) {
                Text("프로필 설정")
                    .font(.rrTitle)
                    .foregroundColor(.rrWhite)

                RRTextField(placeholder: "닉네임", text: $vm.nickname)
                RRTextField(placeholder: "신장 (cm)", text: $vm.heightText)
                RRTextField(placeholder: "체중 (kg)", text: $vm.weightText)
                RRTextField(placeholder: "목표 BPM", text: $vm.goalBPMText)

                Spacer()

                RRPrimaryButton(title: "저장") { vm.save() }
            }
            .padding(24)
        }
    }
}
