import Foundation

/// Acceleration on Apple Watch's three axes, measured in *g*.
public struct ShakeCoordinates: Sendable, Equatable, Codable {
  /// Acceleration along the x-axis.
  public let x: Double

  /// Acceleration along the y-axis.
  public let y: Double

  /// Acceleration along the z-axis.
  public let z: Double

  /// A zero-valued acceleration vector.
  public static let zero = ShakeCoordinates(x: 0, y: 0, z: 0)

  /// Creates an acceleration vector.
  public init(x: Double, y: Double, z: Double) {
    self.x = x
    self.y = y
    self.z = z
  }

  /// The vector's total acceleration magnitude.
  public var magnitude: Double {
    sqrt((x * x) + (y * y) + (z * z))
  }
}
