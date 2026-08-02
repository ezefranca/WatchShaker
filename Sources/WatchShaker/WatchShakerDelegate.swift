#if os(watchOS)
  /// A delegate for imperative WatchKit integrations.
  @MainActor
  public protocol WatchShakerDelegate: AnyObject {
    /// Called when WatchShaker detects a gesture.
    func watchShaker(_ watchShaker: WatchShaker, didDetect shake: Shake)

    /// Called if the motion or runtime session fails.
    func watchShaker(_ watchShaker: WatchShaker, didFailWith error: any Error)

    /// The WatchShaker 1.x delegate callback.
    func watchShaker(
      _ watchShaker: WatchShaker,
      didShakeWith sensibility: ShakeSensitivity,
      direction: ShakeDirection
    )

    /// The WatchShaker 1.x delegate callback without direction.
    func watchShaker(
      _ watchShaker: WatchShaker,
      didShakeWith sensibility: ShakeSensitivity
    )
  }

  extension WatchShakerDelegate {
    public func watchShaker(_ watchShaker: WatchShaker, didDetect shake: Shake) {
      self.watchShaker(
        watchShaker,
        didShakeWith: shake.sensitivity,
        direction: shake.direction
      )
    }

    public func watchShaker(_ watchShaker: WatchShaker, didFailWith error: any Error) {}

    public func watchShaker(
      _ watchShaker: WatchShaker,
      didShakeWith sensibility: ShakeSensitivity,
      direction: ShakeDirection
    ) {
      self.watchShaker(watchShaker, didShakeWith: sensibility)
    }

    public func watchShaker(
      _ watchShaker: WatchShaker,
      didShakeWith sensibility: ShakeSensitivity
    ) {}
  }
#endif
