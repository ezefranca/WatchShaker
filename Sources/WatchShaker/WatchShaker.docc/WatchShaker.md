# ``WatchShaker``

Recognize deliberate shake gestures on Apple Watch with Swift concurrency and native SwiftUI lifecycle support.

## Overview

WatchShaker uses Core Motion's gravity-free user acceleration when available, then applies peak capture, hysteresis, and cooldown before delivering a ``Shake``. The observable controller is main-actor isolated while sensor processing remains on a private serial queue.

For a view-owned feature, start with the `onWatchShake` modifier:

```swift
Text("Shake to continue")
    .onWatchShake { shake in
        continueFlow(direction: shake.direction)
    }
```

Use ``WatchShaker/shakes(bufferingPolicy:)`` when structured concurrency or multiple independent consumers are a better fit.

> Important: The Apple Watch simulator does not provide representative motion samples. Tune detection on hardware.

## Topics

### Essentials

- <doc:GettingStarted>
- <doc:DetectionModel>
- <doc:BackgroundMonitoring>
- <doc:MigrationGuide>

### Monitoring

- ``WatchShaker``
- ``WatchShakerConfiguration``
- ``WatchShakerState``
- ``MonitoringMode``
- ``WatchShakerError``

### Events

- ``Shake``
- ``ShakeCoordinates``
- ``ShakeDirection``
- ``ShakeSensitivity``
- ``ShakeHandler``

### Imperative integration

- ``WatchShakerDelegate``
- ``WatchShakerFailureHandler``
