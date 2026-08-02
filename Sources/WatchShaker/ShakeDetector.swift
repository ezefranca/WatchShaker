import Foundation

struct MotionSample: Sendable, Equatable {
  let acceleration: ShakeCoordinates
  let timestamp: TimeInterval
}

struct DetectedShake: Sendable, Equatable {
  let direction: ShakeDirection
  let acceleration: ShakeCoordinates
  let sensorTimestamp: TimeInterval
}

/// A deterministic, gravity-independent shake detector.
struct ShakeDetector: Sendable {
  private struct Candidate: Sendable {
    let startedAt: TimeInterval
    var peak: MotionSample
  }

  private enum Phase: Sendable {
    case ready
    case capturing(Candidate)
    case coolingDown(until: TimeInterval)
  }

  private var configuration: WatchShakerConfiguration
  private var phase: Phase = .ready
  private var lastTimestamp: TimeInterval?

  init(configuration: WatchShakerConfiguration) {
    self.configuration = configuration
  }

  mutating func updateConfiguration(_ configuration: WatchShakerConfiguration) {
    self.configuration = configuration
    reset()
  }

  mutating func reset() {
    phase = .ready
    lastTimestamp = nil
  }

  mutating func process(_ sample: MotionSample) -> DetectedShake? {
    guard sample.timestamp.isFinite,
      sample.acceleration.x.isFinite,
      sample.acceleration.y.isFinite,
      sample.acceleration.z.isFinite
    else {
      return nil
    }

    if let lastTimestamp, sample.timestamp < lastTimestamp {
      reset()
    }
    lastTimestamp = sample.timestamp

    let magnitude = sample.acceleration.magnitude
    let triggerThreshold = configuration.sensitivity.rawValue
    let releaseThreshold = triggerThreshold * configuration.releaseThresholdRatio

    switch phase {
    case .ready:
      guard magnitude >= triggerThreshold else { return nil }
      phase = .capturing(Candidate(startedAt: sample.timestamp, peak: sample))
      return configuration.peakCaptureDuration == 0
        ? finishCandidate(at: sample.timestamp)
        : nil

    case .capturing(var candidate):
      if magnitude > candidate.peak.acceleration.magnitude {
        candidate.peak = sample
      }

      let captureExpired =
        sample.timestamp - candidate.startedAt
        >= configuration.peakCaptureDuration
      let movementReleased = magnitude <= releaseThreshold

      if captureExpired || movementReleased {
        phase = .capturing(candidate)
        return finishCandidate(at: sample.timestamp)
      }

      phase = .capturing(candidate)
      return nil

    case .coolingDown(let until):
      guard sample.timestamp >= until, magnitude <= releaseThreshold else {
        return nil
      }
      phase = .ready
      return nil
    }
  }

  private mutating func finishCandidate(at timestamp: TimeInterval) -> DetectedShake? {
    guard case .capturing(let candidate) = phase else { return nil }

    phase = .coolingDown(until: timestamp + configuration.cooldown)
    return DetectedShake(
      direction: .direction(
        for: candidate.peak.acceleration,
        minimumDominance: configuration.directionDominance
      ),
      acceleration: candidate.peak.acceleration,
      sensorTimestamp: candidate.peak.timestamp
    )
  }
}

/// Removes the slowly changing gravity component when only raw acceleration is available.
struct GravityRemovalFilter: Sendable {
  private var gravity: ShakeCoordinates?
  private var lastTimestamp: TimeInterval?
  private let timeConstant: TimeInterval

  init(timeConstant: TimeInterval = 0.8) {
    self.timeConstant = timeConstant
  }

  mutating func process(_ sample: MotionSample) -> MotionSample {
    guard let previousGravity = gravity,
      let lastTimestamp,
      sample.timestamp > lastTimestamp
    else {
      gravity = sample.acceleration
      self.lastTimestamp = sample.timestamp
      return MotionSample(acceleration: .zero, timestamp: sample.timestamp)
    }

    let elapsed = sample.timestamp - lastTimestamp
    let retainedGravity = exp(-elapsed / timeConstant)
    let newGravity = ShakeCoordinates(
      x: retainedGravity * previousGravity.x + (1 - retainedGravity) * sample.acceleration.x,
      y: retainedGravity * previousGravity.y + (1 - retainedGravity) * sample.acceleration.y,
      z: retainedGravity * previousGravity.z + (1 - retainedGravity) * sample.acceleration.z
    )
    gravity = newGravity
    self.lastTimestamp = sample.timestamp

    return MotionSample(
      acceleration: ShakeCoordinates(
        x: sample.acceleration.x - newGravity.x,
        y: sample.acceleration.y - newGravity.y,
        z: sample.acceleration.z - newGravity.z
      ),
      timestamp: sample.timestamp
    )
  }
}
