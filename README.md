
# WatchShaker

Native shake detection for Apple Watch, designed for Swift 6 and SwiftUI.

[![CI](https://github.com/ezefranca/WatchShaker/actions/workflows/swift.yml/badge.svg)](https://github.com/ezefranca/WatchShaker/actions/workflows/swift.yml)
[![Documentation](https://img.shields.io/badge/documentation-DocC-0A84FF.svg?logo=swift&logoColor=white)](https://ezefranca.com/WatchShaker/documentation/watchshaker/)
[![Swift Package Index: Swift versions](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fezefranca%2FWatchShaker%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/ezefranca/WatchShaker)
[![Swift Package Index: platforms](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fezefranca%2FWatchShaker%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/ezefranca/WatchShaker)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.21763478.svg)](https://doi.org/10.5281/10.5281/zenodo.21763478)

WatchShaker turns gravity-free Core Motion samples into deliberate, debounced shake events. It offers a view-lifecycle SwiftUI modifier, observable state, broadcast async streams, imperative callbacks, and capability-aware extended runtime support.

## Why WatchShaker

- Swift 6 strict-concurrency safety with main-actor observable state
- Native SwiftUI lifecycle through `.onWatchShake`
- Independent `AsyncStream` subscriptions for structured concurrency
- Peak capture, hysteresis, cooldown, and monotonic sensor timing
- Device-motion user acceleration with a filtered accelerometer fallback
- Extended runtime integration without pretending watchOS allows unrestricted background work
- Codable, Sendable event value types and deterministic Swift Testing coverage

## Requirements

- watchOS 10 or later
- Swift 6 language mode
- Xcode 16 or later

The simulator doesn't provide representative motion data. Validate gesture thresholds and background behavior on Apple Watch hardware.

Keep one WatchShaker instance active at a time. The package shares one `CMMotionManager`, following Core Motion's guidance and avoiding competing sampling rates.

## Installation

Add WatchShaker with Xcode's **File → Add Package Dependencies**, using:

```text
https://github.com/ezefranca/WatchShaker.git
```

Or add it to a package manifest:

```swift
dependencies: [
    .package(
        url: "https://github.com/ezefranca/WatchShaker.git",
        from: "2.0.1"
    )
]
```

## SwiftUI

For most apps, attach the lifecycle-aware modifier to the view that owns the feature:

```swift
import SwiftUI
import WatchShaker

struct ContentView: View {
    @State private var shakeCount = 0

    var body: some View {
        Text("Shakes: \(shakeCount)")
            .onWatchShake { shake in
                shakeCount += 1
                print(shake.direction, shake.acceleration)
            }
    }
}
```

Monitoring starts with the view's task and stops when that task is cancelled.

### Observable state and async events

Use an owned `@State` instance when the UI needs lifecycle or latest-event state. `WatchShaker` uses Observation, so `@StateObject` is no longer appropriate.

```swift
struct MotionView: View {
    @State private var shaker = WatchShaker(
        configuration: .init(sensitivity: .high)
    )

    var body: some View {
        Text(shaker.latestShake?.direction.rawValue ?? "Ready")
            .task {
                let events = shaker.shakes()

                do {
                    try shaker.start(in: .foreground)
                    for await shake in events {
                        print("Peak: \(shake.acceleration.magnitude) g")
                    }
                } catch {
                    print(error.localizedDescription)
                }

                shaker.stop()
            }
    }
}
```

`isAvailable` describes hardware capability. It does **not** indicate that a shake occurred. Read `latestShake`, use `onShake`, or consume `shakes()` for events.

## Configuration

```swift
let configuration = WatchShakerConfiguration(
    sensitivity: .normal,
    sampling: .balanced,
    detection: .balanced
)
```

Higher sensitivity (`.high` or `.veryHigh`) recognizes gentler gestures. Sampling offers `.lowPower`, `.balanced`, and `.responsive`; detection offers `.responsive`, `.balanced`, and `.conservative` profiles. Begin with the balanced defaults and tune on real hardware with the movement your app actually teaches.

Raw detector constants are kept out of the normal initializer. Applications with measured, hardware-specific requirements can create validated custom sampling and detection values. See [Configuration](https://ezefranca.com/WatchShaker/documentation/watchshaker/configuration/).

## Background execution

Yes—WatchShaker can keep monitoring during an eligible watchOS extended runtime session:

```swift
.onWatchShake(mode: .extendedRuntime) { shake in
    handle(shake)
}
```

Your watch app target must enable **Background Modes** and select the session type that truthfully matches the feature. watchOS, not the package, grants runtime and enforces time and energy limits. Physical therapy and smart alarm sessions can run in the background; self care and mindfulness sessions remain frontmost. A workout app should own an `HKWorkoutSession` and use WatchShaker's `.foreground` mode while that workout grants execution time.

See [Background Monitoring](https://ezefranca.com/WatchShaker/documentation/watchshaker/backgroundmonitoring/) before shipping this mode.

## Migrating from 1.x

The current API removes ambiguous fake state and adopts modern naming. Deprecated aliases cover many 1.x spellings, but lifecycle and event handling should be migrated deliberately.

See the [Migration Guide](https://ezefranca.com/WatchShaker/documentation/watchshaker/migrationguide/) for a complete mapping.

## Documentation

Read the [native DocC documentation](https://ezefranca.com/WatchShaker/documentation/watchshaker/) or browse the versioned copy hosted by the [Swift Package Index](https://swiftpackageindex.com/ezefranca/WatchShaker/documentation). The public site also publishes [agent-readable documentation](https://ezefranca.com/WatchShaker/llms.txt) and [structured package context](https://ezefranca.com/WatchShaker/agent-context.json).

- [Getting Started](https://ezefranca.com/WatchShaker/documentation/watchshaker/gettingstarted/)
- [Configuration](https://ezefranca.com/WatchShaker/documentation/watchshaker/configuration/)
- [Background Monitoring](https://ezefranca.com/WatchShaker/documentation/watchshaker/backgroundmonitoring/)
- [Migration Guide](https://ezefranca.com/WatchShaker/documentation/watchshaker/migrationguide/)
- [Detection Model](https://ezefranca.com/WatchShaker/documentation/watchshaker/detectionmodel/)

Build the complete DocC site with:

```sh
xcodebuild docbuild \
  -scheme WatchShaker \
  -destination 'generic/platform=watchOS Simulator'
```

## Research

WatchShaker was presented at **ICECCME 2024**. Read the paper on [IEEE Xplore](https://doi.org/10.1109/iceccme62383.2024.10796862) or view the [preprint](https://cs.paperswithcode.com/paper/experimental-shake-gesture-detection-api-for).

## Contributing and license

Contributions are welcome. Read [CONTRIBUTING.md](CONTRIBUTING.md) and the [security policy](SECURITY.md) before opening a change.

WatchShaker is available under the MIT License. See [LICENSE](LICENSE).
