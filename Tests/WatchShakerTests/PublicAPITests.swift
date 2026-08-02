import Foundation
import Testing

@testable import WatchShaker

@Suite("Public value types")
struct PublicAPITests {
  @Test(
    "Classifies dominant movement",
    arguments: [
      (ShakeCoordinates(x: 2, y: 0, z: 0), ShakeDirection.right),
      (ShakeCoordinates(x: -2, y: 0, z: 0), ShakeDirection.left),
      (ShakeCoordinates(x: 0, y: 2, z: 0), ShakeDirection.down),
      (ShakeCoordinates(x: 0, y: -2, z: 0), ShakeDirection.up),
      (ShakeCoordinates(x: 1, y: 1, z: 0), ShakeDirection.unknown),
      (ShakeCoordinates(x: 0, y: 0, z: 2), ShakeDirection.unknown),
    ]
  )
  func classifiesDirection(
    acceleration: ShakeCoordinates,
    expected: ShakeDirection
  ) {
    #expect(
      ShakeDirection.direction(for: acceleration, minimumDominance: 1.1)
        == expected
    )
  }

  @Test("Sensitivity thresholds are ordered from most to least sensitive")
  func sensitivityOrdering() {
    #expect(ShakeSensitivity.veryHigh.rawValue < ShakeSensitivity.high.rawValue)
    #expect(ShakeSensitivity.high.rawValue < ShakeSensitivity.normal.rawValue)
    #expect(ShakeSensitivity.normal.rawValue < ShakeSensitivity.low.rawValue)
    #expect(ShakeSensitivity.low.rawValue < ShakeSensitivity.veryLow.rawValue)
  }

  @Test("Shake is Codable without losing sensor data")
  func shakeCodableRoundTrip() throws {
    let shake = Shake(
      sensitivity: .high,
      direction: .left,
      acceleration: ShakeCoordinates(x: -1.3, y: 0.2, z: 0.1),
      timestamp: Date(timeIntervalSince1970: 1_700_000_000),
      sensorTimestamp: 42.5
    )

    let data = try JSONEncoder().encode(shake)
    let decoded = try JSONDecoder().decode(Shake.self, from: data)
    #expect(decoded == shake)
  }

  @Test("Rejects unsafe custom sampling frequencies")
  func samplingValidation() {
    #expect(throws: WatchShakerError.self) {
      try WatchShakerConfiguration.SamplingRate.custom(hertz: 0)
    }
  }

  @Test("Default configuration exposes semantic balanced presets")
  func configurationDefaults() {
    let configuration = WatchShakerConfiguration()
    #expect(configuration.sampling == .balanced)
    #expect(configuration.detection == .balanced)
    #expect(configuration.sampling.hertz == 50)
    #expect(abs(configuration.updateInterval - 0.02) < 0.000_001)
  }

  @Test("Rejects unsafe custom detection tuning")
  func detectionValidation() {
    #expect(throws: WatchShakerError.self) {
      try WatchShakerConfiguration.DetectionProfile.custom(
        cooldown: 0.3,
        peakCaptureDuration: 0.1,
        releaseThresholdRatio: 1,
        directionDominance: 1.1
      )
    }
  }
}

#if os(watchOS)
  @Suite("WatchShaker lifecycle")
  @MainActor
  struct WatchShakerLifecycleTests {
    @Test("Starts with no fabricated shake event")
    func startsIdle() {
      let shaker = WatchShaker()
      #expect(shaker.state == .idle)
      #expect(shaker.latestShake == nil)
      #expect(!shaker.isMonitoring)
    }
  }
#endif
