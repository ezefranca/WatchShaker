// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WatchShaker",
    platforms: [.watchOS(.v3)],
    products: [
        .library(
        name: "WatchShaker",
        targets: ["WatchShaker"])
    ],
    targets: [
        .target(
            name: "WatchShaker",
            path: "Sources"
        )
    ]
)

