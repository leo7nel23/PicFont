// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Session",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "Session",
            targets: ["Session"]
        ),
    ],
    dependencies: [
        .package(name: "Utility", path: "../Utility")
    ],
    targets: [
        .target(
            name: "Session",
            dependencies: [
                .product(name: "TestHelper", package: "Utility")
            ],
            swiftSettings: [.define("DEBUG_MODE", .when(configuration: .debug))]
        ),
        .testTarget(
            name: "SessionTests",
            dependencies: [
                "Session",
                .product(name: "TestHelper", package: "Utility")
            ]
        )
    ]
)
