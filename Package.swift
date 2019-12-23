// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "FHNetworking",
    platforms: [
        .macOS(.v10_15), .iOS(.v9), .tvOS(.v9),
    ],
    products: [
        .library(
            name: "FHNetworking",
            targets: ["FHNetworking"]
        ),
    ],
    targets: [
        .target(
            name: "FHNetworking",
            dependencies: []
        ),
        .testTarget(
            name: "FHNetworkingTests",
            dependencies: ["FHNetworking"]
        ),
    ]
)
