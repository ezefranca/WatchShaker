# Migrating to WatchShaker 2

Move from implicit, callback-oriented 1.x behavior to explicit lifecycle and event semantics.

## Update requirements

WatchShaker 2 uses Swift 6 language mode, Observation, and watchOS 10 or later. Update the watch target before changing call sites.

## Replace implicit startup

The 1.x initializer started Core Motion immediately. Version 2 creates an idle controller so the feature owner controls battery use and lifecycle.

```swift
// Before
let shaker = WatchShaker(
    shakeSensibility: .shakeSensibilityNormal,
    delay: 0.2
)

// After
let shaker = WatchShaker(
    configuration: .init(
        sensitivity: .normal,
        detection: .responsive
    )
)
try shaker.start(in: .foreground)
```

The old initializer remains as a deprecated bridge.

## Replace raw detector constants

The current initializer uses semantic presets so detector implementation details do not dominate ordinary call sites.

| Previous configuration | Replacement |
| --- | --- |
| `updateInterval` | ``WatchShakerConfiguration/sampling`` |
| `cooldown`, `peakCaptureDuration`, `releaseThresholdRatio`, `directionDominance` | ``WatchShakerConfiguration/detection`` |

Use the balanced defaults first. If physical-device measurements require exact values, create a validated custom sampling rate or detection profile as described in <doc:Configuration>.

## Use Observation in SwiftUI

`WatchShaker` is an `@Observable`, main-actor type. A view that owns it uses `@State`, not `@StateObject`.

```swift
// Before
@StateObject private var shaker = WatchShaker(...)

// After
@State private var shaker = WatchShaker()
```

For a view that only needs an action, remove the stored controller entirely:

```swift
ContentView()
    .onWatchShake { shake in
        handle(shake)
    }
```

## Use real event state

Version 1 initialized `shake` with a fabricated event and exposed writable availability. Version 2 makes event absence explicit.

| WatchShaker 1.x | WatchShaker 2 |
| --- | --- |
| `isShakerAvailable` | ``WatchShaker/isAvailable`` (read-only capability) |
| `shake` | ``WatchShaker/latestShake`` (optional event) |
| `coordinates` | ``WatchShaker/latestAcceleration`` |
| `startWatchShakerUpdates` | ``WatchShaker/onShake`` or ``WatchShaker/shakes(bufferingPolicy:)`` |

Never use `isAvailable` as a shake trigger. It changes only when capability changes, not for each gesture.

## Adopt modern naming

| Deprecated spelling | Replacement |
| --- | --- |
| `ShakeSensibility` | ``ShakeSensitivity`` |
| `.shakeSensibilitySoftest` | ``ShakeSensitivity/veryHigh`` |
| `.shakeSensibilitySoft` | ``ShakeSensitivity/high`` |
| `.shakeSensibilityNormal` | ``ShakeSensitivity/normal`` |
| `.shakeSensibilityHard` | ``ShakeSensitivity/low`` |
| `.shakeSensibilityHardest` | ``ShakeSensitivity/veryLow`` |
| `.shakeDirectionUp` | ``ShakeDirection/up`` |
| `.shakeDirectionDown` | ``ShakeDirection/down`` |
| `.shakeDirectionLeft` | ``ShakeDirection/left`` |
| `.shakeDirectionRight` | ``ShakeDirection/right`` |
| `.shakeDirectionUnknow` | ``ShakeDirection/unknown`` |

The sensitivity thresholds are recalibrated for gravity-free user acceleration. Re-test custom expectations on hardware instead of assuming raw 1.x values produce identical behavior.

## Update delegates

The modern delegate receives the complete value object:

```swift
extension Controller: WatchShakerDelegate {
    func watchShaker(_ watchShaker: WatchShaker, didDetect shake: Shake) {
        print(shake.direction)
    }

    func watchShaker(_ watchShaker: WatchShaker, didFailWith error: Error) {
        report(error)
    }
}
```

Legacy delegate callbacks still route through default implementations, allowing an incremental migration.

## Review background assumptions

Leaving Core Motion active does not itself keep a watch app alive. Use `.extendedRuntime` only with a matching target capability and Apple-approved feature category, or let a real `HKWorkoutSession` provide the host runtime. Read <doc:BackgroundMonitoring> before enabling background behavior.
