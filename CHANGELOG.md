# Changelog

All notable changes to WatchShaker are documented here. The project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

### Added

- Swift 6 language mode and strict-concurrency-safe public value types.
- Native SwiftUI `.onWatchShake` lifecycle integration.
- Broadcast `AsyncStream` subscriptions through `shakes()`.
- Capability-aware `WKExtendedRuntimeSession` support and session recovery.
- Source-controlled DocC guides for setup, detection, background use, and migration.
- Deterministic Swift Testing suites for detector behavior and public value types.

### Changed

- Raised the minimum deployment target to watchOS 10.
- Replaced raw-gravity thresholding with user acceleration, peak capture, hysteresis, and monotonic timing.
- Replaced `ObservableObject`/`@Published` state with main-actor Observation.
- Made startup explicit for new initializers and made the latest shake optional.
- Renamed “sensibility” APIs to the conventional “sensitivity” spelling.

### Fixed

- `isShakerAvailable` is no longer writable or presented as a shake event.
- Starting repeatedly no longer creates duplicate motion streams.
- Stopping now ends both accelerometer and device-motion updates.
- Core Motion callbacks no longer race observable UI state.
- Gravity and sustained movement no longer generate repeated false positives.
- Resolved [#4](https://github.com/ezefranca/WatchShaker/issues/4) with documented, eligibility-aware background monitoring.
- Resolved [#14](https://github.com/ezefranca/WatchShaker/issues/14) with Observation, real optional event state, async events, and native SwiftUI lifecycle support.

## 1.0.0 - 2021-08-19

- Initial public release.
