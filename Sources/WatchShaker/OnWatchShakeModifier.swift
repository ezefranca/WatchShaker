#if os(watchOS)
  import SwiftUI

  private struct OnWatchShakeModifier: ViewModifier {
    let configuration: WatchShakerConfiguration
    let mode: MonitoringMode
    let onError: WatchShakerFailureHandler?
    let action: ShakeHandler

    func body(content: Content) -> some View {
      content.task {
        let shaker = WatchShaker(configuration: configuration)
        let events = shaker.shakes()
        shaker.onError = onError

        do {
          try shaker.start(in: mode)
          for await shake in events {
            guard !Task.isCancelled else { break }
            action(shake)
          }
        } catch let error as WatchShakerError {
          if shaker.lastError != error {
            onError?(error)
          }
        } catch {
          onError?(.motionFailure(error.localizedDescription))
        }

        shaker.stop()
      }
    }
  }

  extension View {
    /// Performs an action for each shake while this view has an active task.
    ///
    /// Monitoring starts when the view appears and stops automatically when the
    /// view disappears or its task is cancelled.
    public func onWatchShake(
      configuration: WatchShakerConfiguration = .init(),
      mode: MonitoringMode = .foreground,
      onError: WatchShakerFailureHandler? = nil,
      perform action: @escaping ShakeHandler
    ) -> some View {
      modifier(
        OnWatchShakeModifier(
          configuration: configuration,
          mode: mode,
          onError: onError,
          action: action
        )
      )
    }
  }
#endif
