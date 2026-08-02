import Foundation

/// Detection and sampling options for ``WatchShaker``.
///
/// The common API is intentionally expressed as semantic choices instead of
/// exposing detector constants. Use ``SamplingRate/custom(_:)`` or
/// ``DetectionProfile/custom(_:)`` only when hardware testing shows that a
/// preset does not fit your gesture.
public struct WatchShakerConfiguration: Sendable, Equatable {
  /// A validated custom Core Motion sampling frequency.
  public struct SamplingFrequency: Sendable, Equatable {
    /// The number of requested samples per second.
    public let hertz: Double

    /// Creates a custom frequency between 5 Hz and 100 Hz.
    public init(hertz: Double) throws {
      guard hertz.isFinite, (5...100).contains(hertz) else {
        throw WatchShakerError.invalidConfiguration(
          "Sampling frequency must be between 5 Hz and 100 Hz."
        )
      }
      self.hertz = hertz
    }
  }

  /// The requested Core Motion sampling rate.
  public enum SamplingRate: Sendable, Equatable {
    /// Requests 25 Hz to reduce energy use when reaction time is less important.
    case lowPower

    /// Requests 50 Hz, balancing gesture detail and energy use.
    case balanced

    /// Requests 100 Hz for gestures that need the shortest sampling interval.
    case responsive

    /// Uses a validated application-specific frequency.
    case custom(SamplingFrequency)

    /// The requested number of samples per second.
    public var hertz: Double {
      switch self {
      case .lowPower: 25
      case .balanced: 50
      case .responsive: 100
      case .custom(let frequency): frequency.hertz
      }
    }

    /// Creates a custom sampling rate between 5 Hz and 100 Hz.
    public static func custom(hertz: Double) throws -> Self {
      .custom(try SamplingFrequency(hertz: hertz))
    }
  }

  /// Validated low-level controls for a custom detection profile.
  ///
  /// Prefer a ``DetectionProfile`` preset unless you have measurements from a
  /// physical Apple Watch that justify custom values.
  public struct DetectionTuning: Sendable, Equatable {
    /// The minimum time between delivered shakes.
    public let cooldown: TimeInterval

    /// How long the detector retains a candidate to find its strongest sample.
    public let peakCaptureDuration: TimeInterval

    /// The fraction of the trigger threshold below which the detector rearms.
    public let releaseThresholdRatio: Double

    /// How strongly one two-dimensional axis must dominate another.
    public let directionDominance: Double

    /// Creates validated custom detector tuning.
    public init(
      cooldown: TimeInterval,
      peakCaptureDuration: TimeInterval,
      releaseThresholdRatio: Double,
      directionDominance: Double
    ) throws {
      guard cooldown.isFinite, (0...10).contains(cooldown) else {
        throw WatchShakerError.invalidConfiguration(
          "Cooldown must be between 0 and 10 seconds."
        )
      }

      guard peakCaptureDuration.isFinite, (0...0.5).contains(peakCaptureDuration) else {
        throw WatchShakerError.invalidConfiguration(
          "Peak capture duration must be between 0 and 0.5 seconds."
        )
      }

      guard releaseThresholdRatio.isFinite, (0.1..<1).contains(releaseThresholdRatio) else {
        throw WatchShakerError.invalidConfiguration(
          "Release threshold ratio must be at least 0.1 and less than 1."
        )
      }

      guard directionDominance.isFinite, (1...3).contains(directionDominance) else {
        throw WatchShakerError.invalidConfiguration(
          "Direction dominance must be between 1 and 3."
        )
      }

      self.cooldown = cooldown
      self.peakCaptureDuration = peakCaptureDuration
      self.releaseThresholdRatio = releaseThresholdRatio
      self.directionDominance = directionDominance
    }

    fileprivate init(
      validatedCooldown cooldown: TimeInterval,
      peakCaptureDuration: TimeInterval,
      releaseThresholdRatio: Double,
      directionDominance: Double
    ) {
      self.cooldown = cooldown
      self.peakCaptureDuration = peakCaptureDuration
      self.releaseThresholdRatio = releaseThresholdRatio
      self.directionDominance = directionDominance
    }
  }

  /// A cohesive set of timing, hysteresis, and direction-classification choices.
  public enum DetectionProfile: Sendable, Equatable {
    /// Rearms sooner and captures a shorter peak window.
    case responsive

    /// Balances reaction time, duplicate suppression, and direction stability.
    case balanced

    /// Requires a clearer release and stronger directional dominance.
    case conservative

    /// Uses validated application-specific detector tuning.
    case custom(DetectionTuning)

    /// Creates a custom profile without leaking unvalidated values into a configuration.
    public static func custom(
      cooldown: TimeInterval,
      peakCaptureDuration: TimeInterval,
      releaseThresholdRatio: Double,
      directionDominance: Double
    ) throws -> Self {
      .custom(
        try DetectionTuning(
          cooldown: cooldown,
          peakCaptureDuration: peakCaptureDuration,
          releaseThresholdRatio: releaseThresholdRatio,
          directionDominance: directionDominance
        )
      )
    }

    var tuning: DetectionTuning {
      switch self {
      case .responsive:
        DetectionTuning(
          validatedCooldown: 0.2,
          peakCaptureDuration: 0.06,
          releaseThresholdRatio: 0.65,
          directionDominance: 1.05
        )
      case .balanced:
        DetectionTuning(
          validatedCooldown: 0.3,
          peakCaptureDuration: 0.1,
          releaseThresholdRatio: 0.55,
          directionDominance: 1.1
        )
      case .conservative:
        DetectionTuning(
          validatedCooldown: 0.5,
          peakCaptureDuration: 0.15,
          releaseThresholdRatio: 0.45,
          directionDominance: 1.25
        )
      case .custom(let tuning):
        tuning
      }
    }
  }

  /// The preset used to derive the trigger acceleration.
  public var sensitivity: ShakeSensitivity

  /// The requested Core Motion sampling rate.
  public var sampling: SamplingRate

  /// The detector's response and duplicate-suppression behavior.
  public var detection: DetectionProfile

  /// Creates a configuration from semantic presets.
  public init(
    sensitivity: ShakeSensitivity = .normal,
    sampling: SamplingRate = .balanced,
    detection: DetectionProfile = .balanced
  ) {
    self.sensitivity = sensitivity
    self.sampling = sampling
    self.detection = detection
  }

  var updateInterval: TimeInterval { 1 / sampling.hertz }
  var cooldown: TimeInterval { detection.tuning.cooldown }
  var peakCaptureDuration: TimeInterval { detection.tuning.peakCaptureDuration }
  var releaseThresholdRatio: Double { detection.tuning.releaseThresholdRatio }
  var directionDominance: Double { detection.tuning.directionDominance }
}
