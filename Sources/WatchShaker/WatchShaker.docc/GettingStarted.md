# Getting Started

Choose the smallest integration that matches your feature's ownership and lifecycle.

Keep one instance active at a time. WatchShaker intentionally shares one Core Motion manager across the process so multiple feature owners cannot silently compete over sensor sampling.

## Attach monitoring to a view

The `onWatchShake` modifier owns a detector for the lifetime of its structured task. It starts when the view appears and stops when the view disappears.

```swift
import SwiftUI
import WatchShaker

struct ConfirmationView: View {
    @State private var isConfirmed = false

    var body: some View {
        Text(isConfirmed ? "Confirmed" : "Shake to confirm")
            .onWatchShake(
                configuration: .init(sensitivity: .normal)
            ) { shake in
                isConfirmed = true
                print(shake.direction)
            }
    }
}
```

## Observe a controller

Create an owned ``WatchShaker`` with `@State`. The class uses the Observation framework and is main-actor isolated.

```swift
struct DetailView: View {
    @State private var shaker = WatchShaker()

    var body: some View {
        VStack {
            Text(shaker.isAvailable ? "Motion ready" : "Motion unavailable")
            Text(shaker.latestShake?.direction.rawValue ?? "No shake yet")
        }
        .task {
            do {
                try shaker.start(in: .foreground)
            } catch {
                print(error.localizedDescription)
            }
        }
        .onDisappear {
            shaker.stop()
        }
    }
}
```

``WatchShaker/isAvailable`` reports sensor capability only. A detected event appears in ``WatchShaker/latestShake`` and is never fabricated during initialization.

## Consume an async stream

Each call to ``WatchShaker/shakes(bufferingPolicy:)`` creates an independent broadcast subscription.

```swift
.task {
    let events = shaker.shakes()

    do {
        try shaker.start(in: .foreground)
        for await shake in events {
            await analytics.record(shake)
        }
    } catch {
        report(error)
    }

    shaker.stop()
}
```

Create the stream before starting if the first event must not be missed. Cancellation removes the subscription automatically.

## Tune detection

Start with ``ShakeSensitivity/normal`` and the balanced sampling and detection presets. Increase sensitivity for gentler movement or decrease it when ordinary wrist movement causes false positives.

```swift
let configuration = WatchShakerConfiguration(
    sensitivity: .high,
    sampling: .balanced,
    detection: .conservative
)
```

Use `.responsive` detection when reaction time matters most, or `.conservative` when duplicate suppression and directional certainty matter more. See <doc:Configuration> before using custom tuning.

Test on each supported watch size and on both wrist orientations. Direction is a convenience derived from the dominant x/y axis; use ``Shake/acceleration`` when the exact vector matters.
