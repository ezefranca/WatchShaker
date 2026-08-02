import Foundation

/// Detection and sampling options for ``WatchShaker``.
public struct WatchShakerConfiguration: Sendable, Equatable {
  /// The preset used to derive the trigger acceleration.
  public var sensitivity: ShakeSensitivity

  /// The interval between Core Motion samples, in seconds.
  public var updateInterval: TimeInterval

  /// The minimum interval between delivered shakes, in seconds.
  public var cooldown: TimeInterval

  /// How long to retain a candidate so its peak sample can be measured.
  public var peakCaptureDuration: TimeInterval

  /// The fraction of the trigger threshold below which the detector rearms.
  public var releaseThresholdRatio: Double

  /// How strongly one two-dimensional axis must dominate another.
  public var directionDominance: Double

  /// Creates a configuration.
  public init(
    sensitivity: ShakeSensitivity = .normal,
    updateInterval: TimeInterval = 1.0 / 50.0,
    cooldown: TimeInterval = 0.3,
    peakCaptureDuration: TimeInterval = 0.1,
    releaseThresholdRatio: Double = 0.55,
    directionDominance: Double = 1.1
  ) {
    self.sensitivity = sensitivity
    self.updateInterval = updateInterval
    self.cooldown = cooldown
    self.peakCaptureDuration = peakCaptureDuration
    self.releaseThresholdRatio = releaseThresholdRatio
    self.directionDominance = directionDominance
  }

  func validate() throws {
    guard updateInterval.isFinite, (0.01...0.2).contains(updateInterval) else {
      throw WatchShakerError.invalidConfiguration(
        "updateInterval must be between 0.01 and 0.2 seconds."
      )
    }
    guard cooldown.isFinite, (0...10).contains(cooldown) else {
      throw WatchShakerError.invalidConfiguration(
        "cooldown must be between 0 and 10 seconds."
      )
    }
    guard peakCaptureDuration.isFinite, (0...0.5).contains(peakCaptureDuration) else {
      throw WatchShakerError.invalidConfiguration(
        "peakCaptureDuration must be between 0 and 0.5 seconds."
      )
    }
    guard releaseThresholdRatio.isFinite,
      (0.1..<1).contains(releaseThresholdRatio)
    else {
      throw WatchShakerError.invalidConfiguration(
        "releaseThresholdRatio must be at least 0.1 and less than 1."
      )
    }
    guard directionDominance.isFinite,
      (1...3).contains(directionDominance)
    else {
      throw WatchShakerError.invalidConfiguration(
        "directionDominance must be between 1 and 3."
      )
    }
  }
}
