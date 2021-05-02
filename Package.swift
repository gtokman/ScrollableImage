// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ScrollableImage",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "ScrollableImage",
            targets: ["ScrollableImage"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "ScrollableImage",
            dependencies: [],
            resources: [
                .process("Images")
            ]
        ),
        .testTarget(
            name: "ScrollableImageTests",
            dependencies: ["ScrollableImage"]),
    ]
)
