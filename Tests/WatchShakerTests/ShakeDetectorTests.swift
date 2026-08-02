import Foundation
import Testing

@testable import WatchShaker

@Suite("Shake detector")
struct ShakeDetectorTests {
  @Test("Captures the peak sample before emitting")
  func capturesPeak() throws {
    let configuration = WatchShakerConfiguration(
      detection: try .custom(
        cooldown: 0.3,
        peakCaptureDuration: 0.1,
        releaseThresholdRatio: 0.55,
        directionDominance: 1.1
      )
    )
    var detector = ShakeDetector(configuration: configuration)

    #expect(detector.process(sample(x: 1.05, at: 1.0)) == nil)
    #expect(detector.process(sample(y: 1.6, at: 1.05)) == nil)

    let detected = detector.process(sample(at: 1.1))
    let result = try #require(detected)
    #expect(result.acceleration == ShakeCoordinates(x: 0, y: 1.6, z: 0))
    #expect(result.direction == .down)
    #expect(result.sensorTimestamp == 1.05)
  }

  @Test("Ignores samples below the selected sensitivity")
  func ignoresSubthresholdMovement() {
    var detector = ShakeDetector(configuration: .init(sensitivity: .normal))

    for index in 0..<100 {
      let result = detector.process(sample(x: 0.8, at: Double(index) * 0.02))
      #expect(result == nil)
    }
  }

  @Test("Uses hysteresis and cooldown to emit once per movement")
  func appliesHysteresisAndCooldown() throws {
    let configuration = WatchShakerConfiguration(
      detection: try .custom(
        cooldown: 0.3,
        peakCaptureDuration: 0,
        releaseThresholdRatio: 0.5,
        directionDominance: 1.1
      )
    )
    var detector = ShakeDetector(configuration: configuration)

    let firstDetection = detector.process(sample(x: 1.2, at: 0))
    let first = try #require(firstDetection)
    #expect(first.direction == .right)
    #expect(detector.process(sample(x: 1.4, at: 0.1)) == nil)
    #expect(detector.process(sample(at: 0.31)) == nil)

    let secondDetection = detector.process(sample(x: -1.3, at: 0.33))
    let second = try #require(secondDetection)
    #expect(second.direction == .left)
  }

  @Test("Resets safely when the monotonic timestamp moves backwards")
  func handlesTimestampReset() throws {
    let configuration = WatchShakerConfiguration(
      detection: try .custom(
        cooldown: 0.3,
        peakCaptureDuration: 0,
        releaseThresholdRatio: 0.55,
        directionDominance: 1.1
      )
    )
    var detector = ShakeDetector(configuration: configuration)

    let firstDetection = detector.process(sample(x: 1.2, at: 10))
    _ = try #require(firstDetection)
    let secondDetection = detector.process(sample(y: -1.4, at: 1))
    let result = try #require(secondDetection)
    #expect(result.direction == .up)
  }

  private func sample(
    x: Double = 0,
    y: Double = 0,
    z: Double = 0,
    at timestamp: TimeInterval
  ) -> MotionSample {
    MotionSample(
      acceleration: ShakeCoordinates(x: x, y: y, z: z),
      timestamp: timestamp
    )
  }
}

@Suite("Gravity removal")
struct GravityRemovalTests {
  @Test("Removes a stable gravity vector")
  func removesGravity() {
    var filter = GravityRemovalFilter()

    for index in 0...50 {
      let filtered = filter.process(
        MotionSample(
          acceleration: ShakeCoordinates(x: 0, y: 0, z: 1),
          timestamp: Double(index) * 0.02
        )
      )
      #expect(filtered.acceleration.magnitude < 0.000_001)
    }
  }

  @Test("Preserves sudden user acceleration")
  func preservesImpulse() {
    var filter = GravityRemovalFilter()
    _ = filter.process(
      MotionSample(
        acceleration: ShakeCoordinates(x: 0, y: 0, z: 1),
        timestamp: 0
      )
    )

    let filtered = filter.process(
      MotionSample(
        acceleration: ShakeCoordinates(x: 1, y: 0, z: 1),
        timestamp: 0.02
      )
    )
    #expect(filtered.acceleration.x > 0.97)
    #expect(abs(filtered.acceleration.z) < 0.000_001)
  }
}
