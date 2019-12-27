// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "FHNetworking",
    platforms: [.iOS(.v9), .macOS(.v10_10), .watchOS(.v2)],
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
