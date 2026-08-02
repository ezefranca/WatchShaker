/// The dominant two-dimensional direction of a shake.
public enum ShakeDirection: String, Sendable, Equatable, Codable, CaseIterable {
  case up
  case down
  case left
  case right
  case unknown

  static func direction(
    for acceleration: ShakeCoordinates,
    minimumDominance: Double
  ) -> ShakeDirection {
    let horizontal = abs(acceleration.x)
    let vertical = abs(acceleration.y)
    let depth = abs(acceleration.z)
    let dominant = max(horizontal, vertical)
    let secondary = min(horizontal, vertical)

    guard dominant > 0,
      dominant >= secondary * minimumDominance,
      dominant >= depth * 0.8
    else {
      return .unknown
    }

    if horizontal > vertical {
      return acceleration.x > 0 ? .right : .left
    }

    return acceleration.y > 0 ? .down : .up
  }
}

extension ShakeDirection {
  @available(*, deprecated, renamed: "up")
  public static var shakeDirectionUp: Self { .up }

  @available(*, deprecated, renamed: "down")
  public static var shakeDirectionDown: Self { .down }

  @available(*, deprecated, renamed: "left")
  public static var shakeDirectionLeft: Self { .left }

  @available(*, deprecated, renamed: "right")
  public static var shakeDirectionRight: Self { .right }

  @available(*, deprecated, renamed: "unknown")
  public static var shakeDirectionUnknow: Self { .unknown }
}
