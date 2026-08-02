/// A main-actor callback invoked when a shake is detected.
public typealias ShakeHandler = @MainActor @Sendable (Shake) -> Void

/// A main-actor callback invoked after monitoring fails.
public typealias WatchShakerFailureHandler = @MainActor @Sendable (WatchShakerError) -> Void

/// The callback shape used by WatchShaker 1.x.
@available(*, deprecated, message: "Use ShakeHandler, onShake, or shakes() instead.")
public typealias WatchShakerHandler =
  @MainActor (
    ShakeSensitivity?,
    ShakeCoordinates?,
    (any Error)?
  ) -> Void
