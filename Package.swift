// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SpanGrid",
    platforms: [
        .iOS(.v14),
        .tvOS(.v14),
        .macOS(.v11),
        .watchOS(.v7),
    ],
    products: [
        .library(name: "SpanGrid", targets: ["SpanGrid"]),
    ],
    dependencies: [
        .package(name: "SnapshotTesting",
                 url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.9.0"),
        
        .package(name: "swift-log",
                 url: "https://github.com/apple/swift-log.git", from: "1.4.2"),
    ],
    targets: [
        .target(
            name: "SpanGrid",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
            ],
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
