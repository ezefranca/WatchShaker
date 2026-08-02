// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "WatchShaker",
  platforms: [
    .watchOS(.v10)
  ],
  products: [
    .library(
      name: "WatchShaker",
      targets: ["WatchShaker"]
    )
  ],
  targets: [
    .target(
      name: "WatchShaker"
    ),
    .testTarget(
      name: "WatchShakerTests",
      dependencies: ["WatchShaker"]
    ),
  ],
  swiftLanguageModes: [.v6]
)
