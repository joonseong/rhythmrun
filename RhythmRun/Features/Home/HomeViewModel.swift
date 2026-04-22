import Foundation
import Combine

final class HomeViewModel: ObservableObject {
    @Published var nickname: String = ""
    @Published var recentSessions: [RunSession] = []
}
