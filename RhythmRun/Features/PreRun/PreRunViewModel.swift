import Foundation

struct SessionConfig {
    var targetBPM: Int = 160
    var targetDistanceKM: Double = 5
    var mode: RunMode = .beatGuide

    enum RunMode {
        case beatGuide
        case freeRun
    }
}

final class PreRunViewModel: ObservableObject {
    @Published var sessionConfig = SessionConfig()
}
