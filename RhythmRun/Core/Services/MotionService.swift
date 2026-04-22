import Foundation
import CoreMotion

protocol MotionServiceProtocol {
    func startDetection(onStep: @escaping (Date) -> Void)
    func stopDetection()
}

final class MotionService: MotionServiceProtocol {
    private let motionManager = CMMotionManager()
    private let updateInterval: TimeInterval = 0.02  // 50Hz
    private var lastPeakTime: Date?
    private let peakCooldown: TimeInterval = 0.25   // 최소 보폭 간격

    func startDetection(onStep: @escaping (Date) -> Void) {
        guard motionManager.isAccelerometerAvailable else { return }
        motionManager.accelerometerUpdateInterval = updateInterval
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, _ in
            guard let self, let data else { return }
            self.detectPeak(z: data.acceleration.z, onStep: onStep)
        }
    }

    func stopDetection() {
        motionManager.stopAccelerometerUpdates()
        lastPeakTime = nil
    }

    private func detectPeak(z: Double, onStep: (Date) -> Void) {
        let threshold = 0.3
        guard z > threshold else { return }

        let now = Date()
        if let last = lastPeakTime, now.timeIntervalSince(last) < peakCooldown { return }
        lastPeakTime = now
        onStep(now)
    }
}
