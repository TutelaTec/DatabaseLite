// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DatabaseLite",
    products: [
        .library(
            name: "DatabaseLite",
            targets: ["DatabaseLite"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "DatabaseLite",
            dependencies: [],
            exclude: ["DatabaseLite/README.md"]
        ),
        .testTarget(
            name: "DatabaseLiteTests",
            dependencies: ["DatabaseLite"]),
    ]
)
