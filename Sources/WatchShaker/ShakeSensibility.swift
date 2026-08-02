/// How readily WatchShaker recognizes movement as a shake.
///
/// Higher sensitivity recognizes gentler movement. Thresholds are calibrated
/// against gravity-free user acceleration rather than raw accelerometer data.
public enum ShakeSensitivity: Double, Sendable, Equatable, Codable, CaseIterable {
  case veryHigh = 0.35
  case high = 0.65
  case normal = 1.0
  case low = 1.35
  case veryLow = 1.75
}

/// The pre-2.0 spelling of ``ShakeSensitivity``.
@available(*, deprecated, renamed: "ShakeSensitivity")
public typealias ShakeSensibility = ShakeSensitivity

extension ShakeSensitivity {
  @available(*, deprecated, renamed: "veryHigh")
  public static var shakeSensibilitySoftest: Self { .veryHigh }

  @available(*, deprecated, renamed: "high")
  public static var shakeSensibilitySoft: Self { .high }

  @available(*, deprecated, renamed: "normal")
  public static var shakeSensibilityNormal: Self { .normal }

  @available(*, deprecated, renamed: "low")
  public static var shakeSensibilityHard: Self { .low }

  @available(*, deprecated, renamed: "veryLow")
  public static var shakeSensibilityHardest: Self { .veryLow }
}
