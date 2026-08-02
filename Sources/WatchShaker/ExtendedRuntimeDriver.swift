#if os(watchOS)
  import Foundation
  import WatchKit

  final class ExtendedRuntimeDriver: NSObject, WKExtendedRuntimeSessionDelegate, @unchecked Sendable
  {
    typealias StartHandler = @Sendable (Date?) -> Void
    typealias ExpirationHandler = @Sendable () -> Void
    typealias InvalidationHandler = @Sendable (String, Bool) -> Void

    let session: WKExtendedRuntimeSession

    private let onStart: StartHandler
    private let onExpiration: ExpirationHandler
    private let onInvalidation: InvalidationHandler

    init(
      session: WKExtendedRuntimeSession = WKExtendedRuntimeSession(),
      onStart: @escaping StartHandler,
      onExpiration: @escaping ExpirationHandler,
      onInvalidation: @escaping InvalidationHandler
    ) {
      self.session = session
      self.onStart = onStart
      self.onExpiration = onExpiration
      self.onInvalidation = onInvalidation
      super.init()
      session.delegate = self
    }

    func start() {
      session.start()
    }

    func invalidate() {
      session.invalidate()
    }

    func extendedRuntimeSessionDidStart(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
      onStart(extendedRuntimeSession.expirationDate)
    }

    func extendedRuntimeSessionWillExpire(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
      onExpiration()
    }

    func extendedRuntimeSession(
      _ extendedRuntimeSession: WKExtendedRuntimeSession,
      didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason,
      error: (any Error)?
    ) {
      let endedNormally = reason == .none
      let description = error?.localizedDescription ?? Self.description(for: reason)
      onInvalidation(description, endedNormally)
    }

    private static func description(
      for reason: WKExtendedRuntimeSessionInvalidationReason
    ) -> String {
      switch reason {
      case .none:
        "The session was stopped."
      case .sessionInProgress:
        "Another extended runtime session is already running."
      case .expired:
        "The session reached its system time limit."
      case .resignedFrontmost:
        "The app lost frontmost status for this session type."
      case .suppressedBySystem:
        "The system suppressed the session."
      case .error:
        "The session ended with an unknown error."
      @unknown default:
        "The session ended for an unknown reason."
      }
    }
  }
#endif
