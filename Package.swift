// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

public let package = Package(
    name: "HighlightedTextEditor",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "HighlightedTextEditor",
            targets: ["HighlightedTextEditor"]
        )
    ],
    targets: [
        .target(
            name: "HighlightedTextEditor",
            dependencies: []
        )
    ]
)
