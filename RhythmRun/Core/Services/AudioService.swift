import Foundation
import AVFoundation

protocol AudioServiceProtocol {
    func startBeat(bpm: Int)
    func stopBeat()
}

final class AudioService: AudioServiceProtocol {
    private var timer: Timer?
    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()

    func startBeat(bpm: Int) {
        stopBeat()
        guard bpm > 0 else { return }
        let interval = 60.0 / Double(bpm)
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.playClick()
        }
    }

    func stopBeat() {
        timer?.invalidate()
        timer = nil
    }

    private func playClick() {
        // TODO: AVAudioEngine으로 실제 클릭 사운드 재생
        AudioServicesPlaySystemSound(1104)
    }
}
