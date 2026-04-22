import Foundation
import Combine

final class LiveSessionViewModel: ObservableObject {
    @Published var currentBPM: Int = 0
    @Published var combo: Int = 0
    @Published var score: Int = 0
    @Published var elapsedSeconds: Int = 0

    private let config: SessionConfig
    private let motionService: MotionServiceProtocol
    private let audioService: AudioServiceProtocol
    private let bpmEngine: BPMEngineProtocol
    private var timer: Timer?

    init(
        config: SessionConfig,
        motionService: MotionServiceProtocol = MotionService(),
        audioService: AudioServiceProtocol = AudioService(),
        bpmEngine: BPMEngineProtocol = BPMEngine()
    ) {
        self.config = config
        self.motionService = motionService
        self.audioService = audioService
        self.bpmEngine = bpmEngine
    }

    func startSession() {
        motionService.startDetection { [weak self] timestamp in
            guard let self else { return }
            self.bpmEngine.recordStep(at: timestamp)
            DispatchQueue.main.async {
                self.currentBPM = self.bpmEngine.currentBPM
            }
        }
        if config.mode == .beatGuide {
            audioService.startBeat(bpm: config.targetBPM)
        }
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.elapsedSeconds += 1
        }
    }

    func endSession() {
        motionService.stopDetection()
        audioService.stopBeat()
        timer?.invalidate()
        timer = nil
    }
}
