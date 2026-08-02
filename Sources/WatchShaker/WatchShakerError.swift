import Foundation

/// Errors reported by WatchShaker.
public enum WatchShakerError: Error, Sendable, Equatable {
  case motionUnavailable
  case monitoringAlreadyActive
  case invalidConfiguration(String)
  case motionFailure(String)
  case backgroundSessionInvalidated(reason: String)
}

extension WatchShakerError: LocalizedError {
  public var errorDescription: String? {
    switch self {
    case .motionUnavailable:
      "Motion data is unavailable on this device."
    case .monitoringAlreadyActive:
      "Another WatchShaker instance is already monitoring motion."
    case .invalidConfiguration(let message):
      "Invalid WatchShaker configuration: \(message)"
    case .motionFailure(let message):
      "Core Motion stopped delivering data: \(message)"
    case .backgroundSessionInvalidated(let reason):
      "The extended runtime session ended: \(reason)"
    }
  }
}
