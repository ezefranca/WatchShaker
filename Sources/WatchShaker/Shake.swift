import Foundation

/// A single detected shake.
public struct Shake: Sendable, Equatable, Codable {
  /// The configured sensitivity when the shake was detected.
  public let sensitivity: ShakeSensitivity

  /// The dominant direction of movement.
  public let direction: ShakeDirection

  /// The peak gravity-free acceleration observed during the gesture.
  public let acceleration: ShakeCoordinates

  /// The wall-clock time at which WatchShaker delivered the gesture.
  public let timestamp: Date

  /// Core Motion's monotonic timestamp for the peak sample.
  public let sensorTimestamp: TimeInterval

  /// Creates a shake event.
  public init(
    sensitivity: ShakeSensitivity,
    direction: ShakeDirection,
    acceleration: ShakeCoordinates,
    timestamp: Date = Date(),
    sensorTimestamp: TimeInterval
  ) {
    self.sensitivity = sensitivity
    self.direction = direction
    self.acceleration = acceleration
    self.timestamp = timestamp
    self.sensorTimestamp = sensorTimestamp
  }

  /// The pre-2.0 spelling of ``sensitivity``.
  @available(*, deprecated, renamed: "sensitivity")
  public var sensibility: ShakeSensitivity { sensitivity }

  /// The pre-2.0 spelling of ``timestamp``.
  @available(*, deprecated, renamed: "timestamp")
  public var time: Date { timestamp }

  /// Creates a legacy event without a Core Motion sample.
  @available(
    *, deprecated,
    message: "Use init(sensitivity:direction:acceleration:timestamp:sensorTimestamp:)"
  )
  public init(sensibility: ShakeSensitivity, direction: ShakeDirection, time: Date) {
    self.init(
      sensitivity: sensibility,
      direction: direction,
      acceleration: .zero,
      timestamp: time,
      sensorTimestamp: 0
    )
  }
}
