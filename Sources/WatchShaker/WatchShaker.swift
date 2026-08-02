#if os(watchOS)
  import Foundation
  import Observation
  import WatchKit

  /// How WatchShaker receives execution time.
  public enum MonitoringMode: Sendable, Equatable {
    /// Monitor while the host app is running, including during a host-managed workout.
    case foreground

    /// Ask watchOS for an extended runtime session before monitoring.
    case extendedRuntime
  }

  /// The current lifecycle state of a ``WatchShaker`` instance.
  public enum WatchShakerState: Sendable, Equatable {
    case idle
    case starting(MonitoringMode)
    case monitoring(MonitoringMode)
  }

  /// Detects shake gestures from Apple Watch motion data.
  ///
  /// `WatchShaker` is main-actor isolated so its observable state is safe to read
  /// directly from SwiftUI. Core Motion processing happens on a private serial queue.
  @MainActor
  @Observable
  public final class WatchShaker {
    /// The active detection options.
    public private(set) var configuration: WatchShakerConfiguration

    /// The latest detected shake, or `nil` before the first gesture.
    public private(set) var latestShake: Shake?

    /// The peak acceleration from ``latestShake``.
    public private(set) var latestAcceleration: ShakeCoordinates?

    /// The monitoring lifecycle state.
    public private(set) var state: WatchShakerState = .idle

    /// The latest runtime error.
    public private(set) var lastError: WatchShakerError?

    /// The expiration date supplied by the active extended runtime session.
    public private(set) var backgroundSessionExpirationDate: Date?

    /// An imperative callback for detected shakes.
    @ObservationIgnored public var onShake: ShakeHandler?

    /// An imperative callback for failures.
    @ObservationIgnored public var onError: WatchShakerFailureHandler?

    /// Called shortly before an extended runtime session expires.
    @ObservationIgnored public var onBackgroundSessionWillExpire: (@MainActor @Sendable () -> Void)?

    /// An optional delegate for WatchKit-style integrations.
    @ObservationIgnored public weak var delegate: (any WatchShakerDelegate)?

    /// The WatchShaker 1.x callback.
    @available(*, deprecated, message: "Use onShake or shakes() instead.")
    public var startWatchShakerUpdates: WatchShakerHandler? {
      get { legacyHandler }
      set { legacyHandler = newValue }
    }

    @ObservationIgnored private let source: CoreMotionSource
    @ObservationIgnored private let sourceOwner = UUID()
    @ObservationIgnored private var streams: [UUID: AsyncStream<Shake>.Continuation] = [:]
    @ObservationIgnored private var backgroundDriver: ExtendedRuntimeDriver?
    @ObservationIgnored private var backgroundToken: UUID?
    @ObservationIgnored private var legacyHandler:
      (
        @MainActor (
          ShakeSensitivity?,
          ShakeCoordinates?,
          (any Error)?
        ) -> Void
      )?

    /// Creates an idle detector. Call ``start(in:)`` when the feature becomes active.
    public init(configuration: WatchShakerConfiguration = .init()) {
      self.configuration = configuration
      self.source = .shared
    }

    /// Whether Core Motion can supply the data required by WatchShaker.
    public var isAvailable: Bool { source.isAvailable }

    /// Whether motion samples are currently being processed.
    public var isMonitoring: Bool {
      if case .monitoring = state { true } else { false }
    }

    /// Starts monitoring in the requested lifecycle mode.
    ///
    /// Calling this while the instance is already starting or monitoring is a no-op.
    public func start(in mode: MonitoringMode = .foreground) throws {
      do {
        try configuration.validate()
      } catch let error as WatchShakerError {
        report(error)
        throw error
      }
      guard state == .idle else { return }
      guard isAvailable else {
        let error = WatchShakerError.motionUnavailable
        report(error)
        throw error
      }

      lastError = nil
      switch mode {
      case .foreground:
        try beginMotion(mode: mode)
      case .extendedRuntime:
        try beginExtendedRuntime()
      }
    }

    /// Stops motion updates and ends any extended runtime session owned by this instance.
    public func stop() {
      source.stop(owner: sourceOwner)
      state = .idle
      backgroundSessionExpirationDate = nil
      backgroundToken = nil

      let driver = backgroundDriver
      backgroundDriver = nil
      driver?.invalidate()
    }

    /// Applies a new validated configuration.
    public func updateConfiguration(_ configuration: WatchShakerConfiguration) throws {
      try configuration.validate()
      self.configuration = configuration
      if isMonitoring {
        source.updateConfiguration(configuration, owner: sourceOwner)
      }
    }

    /// Creates a broadcast stream for this instance's shake events.
    ///
    /// Each call creates an independent subscription. The stream ends when the
    /// consuming task is cancelled or this instance is released.
    public func shakes(
      bufferingPolicy: AsyncStream<Shake>.Continuation.BufferingPolicy = .bufferingNewest(1)
    ) -> AsyncStream<Shake> {
      let identifier = UUID()
      return AsyncStream(bufferingPolicy: bufferingPolicy) { continuation in
        streams[identifier] = continuation
        continuation.onTermination = { @Sendable [weak self] _ in
          Task { @MainActor [weak self] in
            self?.streams.removeValue(forKey: identifier)
          }
        }
      }
    }

    /// Adopts a runtime session delivered to the host app delegate by watchOS.
    ///
    /// Call this from `handle(_:)`/`handleExtendedRuntimeSession(_:)` before the
    /// delegate callback returns so WatchShaker can resume scheduled monitoring.
    public func adoptExtendedRuntimeSession(
      _ session: WKExtendedRuntimeSession
    ) throws {
      try configuration.validate()
      guard state == .idle else { return }
      guard isAvailable else { throw WatchShakerError.motionUnavailable }

      installDriver(for: session)
      state = .starting(.extendedRuntime)

      switch session.state {
      case .running:
        backgroundSessionExpirationDate = session.expirationDate
        try beginMotion(mode: .extendedRuntime)
      case .notStarted, .scheduled:
        break
      case .invalid:
        backgroundDriver = nil
        backgroundToken = nil
        state = .idle
        let error = WatchShakerError.backgroundSessionInvalidated(
          reason: "watchOS delivered an invalid session."
        )
        report(error)
        throw error
      @unknown default:
        break
      }
    }

    deinit {
      source.stop(owner: sourceOwner)
      for continuation in streams.values {
        continuation.finish()
      }
    }

    private func beginMotion(mode: MonitoringMode) throws {
      do {
        try source.start(
          owner: sourceOwner,
          configuration: configuration,
          onDetection: { [weak self] detection in
            Task { @MainActor [weak self] in
              self?.receive(detection)
            }
          },
          onFailure: { [weak self] error in
            Task { @MainActor [weak self] in
              self?.motionDidFail(error)
            }
          }
        )
        state = .monitoring(mode)
      } catch let error as WatchShakerError {
        report(error)
        throw error
      }
    }

    private func beginExtendedRuntime() throws {
      guard WKApplication.shared().applicationState == .active else {
        let error = WatchShakerError.backgroundSessionInvalidated(
          reason: "Start an extended runtime session while the app is active."
        )
        report(error)
        throw error
      }

      let session = WKExtendedRuntimeSession()
      installDriver(for: session)
      state = .starting(.extendedRuntime)
      backgroundDriver?.start()
    }

    private func installDriver(for session: WKExtendedRuntimeSession) {
      let token = UUID()
      backgroundToken = token
      backgroundDriver = ExtendedRuntimeDriver(
        session: session,
        onStart: { [weak self] expirationDate in
          Task { @MainActor [weak self] in
            self?.extendedRuntimeDidStart(token: token, expirationDate: expirationDate)
          }
        },
        onExpiration: { [weak self] in
          Task { @MainActor [weak self] in
            guard self?.backgroundToken == token else { return }
            self?.onBackgroundSessionWillExpire?()
          }
        },
        onInvalidation: { [weak self] reason, endedNormally in
          Task { @MainActor [weak self] in
            self?.extendedRuntimeDidEnd(
              token: token,
              reason: reason,
              endedNormally: endedNormally
            )
          }
        }
      )
    }

    private func extendedRuntimeDidStart(token: UUID, expirationDate: Date?) {
      guard backgroundToken == token else { return }
      backgroundSessionExpirationDate = expirationDate
      do {
        try beginMotion(mode: .extendedRuntime)
      } catch {
        backgroundDriver?.invalidate()
      }
    }

    private func extendedRuntimeDidEnd(
      token: UUID,
      reason: String,
      endedNormally: Bool
    ) {
      guard backgroundToken == token else { return }
      source.stop(owner: sourceOwner)
      state = .idle
      backgroundDriver = nil
      backgroundToken = nil
      backgroundSessionExpirationDate = nil

      if !endedNormally {
        report(.backgroundSessionInvalidated(reason: reason))
      }
    }

    private func receive(_ detection: DetectedShake) {
      guard case .monitoring = state else { return }
      let shake = Shake(
        sensitivity: configuration.sensitivity,
        direction: detection.direction,
        acceleration: detection.acceleration,
        sensorTimestamp: detection.sensorTimestamp
      )
      latestAcceleration = detection.acceleration
      latestShake = shake

      delegate?.watchShaker(self, didDetect: shake)
      onShake?(shake)
      legacyHandler?(shake.sensitivity, shake.acceleration, nil)
      for continuation in streams.values {
        continuation.yield(shake)
      }
    }

    private func motionDidFail(_ error: WatchShakerError) {
      source.stop(owner: sourceOwner)
      state = .idle
      backgroundSessionExpirationDate = nil
      backgroundToken = nil

      let driver = backgroundDriver
      backgroundDriver = nil
      driver?.invalidate()
      report(error)
    }

    private func report(_ error: WatchShakerError) {
      lastError = error
      delegate?.watchShaker(self, didFailWith: error)
      onError?(error)
      legacyHandler?(nil, nil, error)
    }
  }

  extension WatchShaker {
    /// The WatchShaker 1.x initializer. New code should create an idle instance.
    @available(*, deprecated, message: "Use init(configuration:) and start(in:) instead.")
    public convenience init(shakeSensibility: ShakeSensitivity, delay: TimeInterval) {
      self.init(
        configuration: WatchShakerConfiguration(
          sensitivity: shakeSensibility,
          cooldown: delay
        )
      )
      do {
        try start(in: .foreground)
      } catch let error as WatchShakerError {
        report(error)
      } catch {
        report(.motionFailure(error.localizedDescription))
      }
    }

    /// The WatchShaker 1.x availability spelling.
    @available(*, deprecated, renamed: "isAvailable")
    public var isShakerAvailable: Bool { isAvailable }

    /// The WatchShaker 1.x latest event spelling.
    @available(*, deprecated, renamed: "latestShake")
    public var shake: Shake? { latestShake }

    /// The WatchShaker 1.x acceleration spelling.
    @available(*, deprecated, renamed: "latestAcceleration")
    public var coordinates: ShakeCoordinates? { latestAcceleration }

    /// Starts foreground monitoring using the WatchShaker 1.x call shape.
    @available(*, deprecated, message: "Use start(in:) and configuration.updateInterval instead.")
    public func start(delay accelerometerUpdateInterval: TimeInterval = 1.0 / 50.0) {
      do {
        var updated = configuration
        updated.updateInterval = accelerometerUpdateInterval
        try updateConfiguration(updated)
        try start(in: .foreground)
      } catch let error as WatchShakerError {
        report(error)
      } catch {
        report(.motionFailure(error.localizedDescription))
      }
    }

    /// Updates sensitivity using the WatchShaker 1.x call shape.
    @available(*, deprecated, message: "Use updateConfiguration(_:) instead.")
    public func threshold(new sensitivity: ShakeSensitivity) {
      var updated = configuration
      updated.sensitivity = sensitivity
      try? updateConfiguration(updated)
    }

    /// Updates cooldown using the WatchShaker 1.x call shape.
    @available(*, deprecated, message: "Use updateConfiguration(_:) instead.")
    public func delay(value: TimeInterval) {
      var updated = configuration
      updated.cooldown = value
      try? updateConfiguration(updated)
    }
  }
#endif
