# Changelog

All notable changes to WatchShaker are documented here. The project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.1.0] - 2026-08-14

### Fixed

- Configured `.spi.yml` with `external_links.documentation` so the Swift Package Index links to the self-hosted DocC site instead of attempting an unsupported watchOS documentation build, restoring the Documentation score on the package's Swift Package Index listing.

### Changed

- Updated the README's Documentation section to describe the self-hosted documentation setup and link to Swift Package Index maintainer information.

## [2.0.1] - 2026-08-02

### Added

- Automated deployment of the native DocC experience to GitHub Pages.
- Search-engine metadata, canonical URLs, a sitemap, and route-specific HTML entry points for DocC.
- Agent-readable `llms.txt`, `llms-full.txt`, and structured package context alongside the human documentation.
- Swift Package Index configuration for watchOS compatibility builds and hosted DocC documentation.
- Live Swift version and platform compatibility badges backed by Swift Package Index build results.

### Changed

- Linked the README to the deployed, native DocC guides and API reference.

## [2.0.0] - 2026-08-02

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
- Replaced public detector constants with semantic sampling and detection presets, while retaining validated custom tuning.

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

[Unreleased]: https://github.com/ezefranca/WatchShaker/compare/2.1.0...HEAD
[2.1.0]: https://github.com/ezefranca/WatchShaker/compare/2.0.1...2.1.0
[2.0.1]: https://github.com/ezefranca/WatchShaker/compare/2.0.0...2.0.1
[2.0.0]: https://github.com/ezefranca/WatchShaker/compare/1.0.0...2.0.0
