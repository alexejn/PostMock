// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PostMock",
    platforms: [
            .iOS(.v14)
        ],
    products: [
        .library(name: "PostMock", targets: ["PostMock"])
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "PostMock",
            path: "Sources"),
        .testTarget(
            name: "PostMockTests",
            dependencies: ["PostMock"], 
            path: "Tests"),
    ]
)
