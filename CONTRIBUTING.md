# Contributing to WatchShaker

Thank you for improving WatchShaker. Focused issues and pull requests are welcome.

## Development setup

Use Xcode 16 or later with a Swift 6 toolchain.

```sh
xcrun swift-format lint --strict --recursive Sources Tests Package.swift
swift test
xcodebuild build \
  -scheme WatchShaker \
  -destination 'generic/platform=watchOS Simulator' \
  CODE_SIGNING_ALLOWED=NO
xcodebuild docbuild \
  -scheme WatchShaker \
  -destination 'generic/platform=watchOS Simulator' \
  CODE_SIGNING_ALLOWED=NO
```

Run detector tests on the host for fast feedback. Validate Core Motion behavior on a physical Apple Watch before proposing threshold or lifecycle changes.

## Pull requests

- Explain the user-visible problem and why the change is appropriately scoped.
- Add deterministic tests for detection or value-semantic behavior.
- Update DocC and the migration guide when public API behavior changes.
- Avoid logging motion samples or other user data.
- Preserve source compatibility when it doesn't compromise correctness; otherwise document the break under `Unreleased`.

## Reporting motion behavior

Include the Apple Watch model, watchOS version, wrist orientation, configuration, and a reproducible description of the gesture. Do not attach health data or personally identifying sensor traces.
