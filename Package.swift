// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SpanGrid",
    platforms: [
        .iOS(.v14),
    ],
    products: [
        .library(name: "SpanGrid", targets: ["SpanGrid"]),
    ],
    dependencies: [
        .package(name: "SnapshotTesting",
                 url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.9.0"),
    ],
    targets: [
        .target(
            name: "SpanGrid",
            path: "Sources"
        ),
        .testTarget(
            name: "SpanGridTests",
            dependencies: [
                .product(name: "SnapshotTesting", package: "SnapshotTesting"),
                .target(name: "SpanGrid"),
            ],
            path: "Tests",
            exclude: [ "__Snapshots__" ]
        ),
    ]
)
