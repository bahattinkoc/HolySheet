// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "HolySheet",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "HolySheet",
            targets: ["HolySheet"]),
    ],
    targets: [
        .target(
            name: "HolySheet"),

    ]
)
