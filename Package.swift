// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DatabaseLite",
//    products: [
//        // Products define the executables and libraries a package produces, and make them visible to other packages.
//        .library(
//            name: "DatabaseLite",
//            targets: ["DatabaseLite"]),
//    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.4.0"),
        .package(url: "https://github.com/AutomatonTec/Spreadsheet", from: "1.0.5-beta.2"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .executableTarget(
            name: "DatabaseLite",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Spreadsheet", package: "Spreadsheet"),
            ],
            exclude: ["DatabaseLite/README.md"]),
        .testTarget(
            name: "DatabaseLiteTests",
            dependencies: ["DatabaseLite"]),
    ]
)
