# Background Monitoring

Keep detecting shakes only while watchOS grants your app an eligible runtime session.

## Understand the boundary

watchOS normally suspends an app after the user lowers their wrist or leaves the app. A Swift package cannot bypass that lifecycle. WatchShaker can own a `WKExtendedRuntimeSession`, but the host target must declare a valid session category and watchOS decides whether and how long it runs.

Apple defines four extended runtime categories:

- **Physical therapy** runs in the background for a limited period.
- **Smart alarm** runs in the background and may be scheduled.
- **Self care** and **mindfulness** remain frontmost even when the display sleeps.

Choose a category because it truthfully describes the feature, not simply to gain background execution. See Apple's [Using extended runtime sessions](https://developer.apple.com/documentation/watchkit/using-extended-runtime-sessions) documentation for current behavior and limits.

## Configure the target

In the watch app target:

1. Open **Signing & Capabilities**.
2. Add **Background Modes**.
3. Select the extended runtime session type that matches the app's purpose.
4. Test time limits, energy use, interruptions, and invalidation on Apple Watch hardware.

The package cannot add this capability to an app target.

## Start an extended runtime session

Start while the watch app is active:

```swift
Text("Monitoring")
    .onWatchShake(
        mode: .extendedRuntime,
        onError: { error in present(error) }
    ) { shake in
        process(shake)
    }
```

Or retain the controller directly:

```swift
try shaker.start(in: .extendedRuntime)
```

The state moves from ``WatchShakerState/starting(_:)`` to ``WatchShakerState/monitoring(_:)`` only after watchOS starts the session. ``WatchShaker/backgroundSessionExpirationDate`` exposes the system's current expiration date, and `onBackgroundSessionWillExpire` provides a cleanup opportunity.

## Resume a delivered session

For a session that watchOS delivers back to the app delegate, adopt it before the delegate method returns:

```swift
@MainActor
func handle(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
    do {
        try shaker.adoptExtendedRuntimeSession(extendedRuntimeSession)
    } catch {
        report(error)
    }
}
```

This is particularly important for a scheduled session whose app process was suspended or terminated.

## Workouts

If gesture detection is part of a real workout, the app should own and correctly configure an `HKWorkoutSession`. An active workout already grants appropriate runtime, so start WatchShaker with `.foreground`; don't create an unrelated extended runtime session. Apple's [Running workout sessions](https://developer.apple.com/documentation/healthkit/running-workout-sessions) guide describes workout processing and HealthKit requirements.

## Energy behavior

The default 50 Hz rate balances latency with processing cost. WatchShaker does constant-time work on a serial queue and emits only completed gestures. Still, profile the full app on hardware: watchOS can invalidate extended sessions that sustain excessive CPU use.
