import Foundation

final class ProfileViewModel: ObservableObject {
    @Published var nickname: String = ""
    @Published var heightText: String = ""
    @Published var weightText: String = ""
    @Published var goalBPMText: String = ""

    func save() {
        // TODO: UserDefaults 또는 SessionStore에 저장
    }
}
