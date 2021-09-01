// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "shake256-swift",
    products: [
        .library(
            name: "SHAKE256",
            targets: ["SHAKE256"]),
    ],
    dependencies: [
        .package(url: "https://github.com/nixberg/hexstring-swift", from: "0.2.0"),
    ],
    targets: [
        .target(
            name: "SHAKE256"),
        .testTarget(
            name: "SHAKE256Tests",
            dependencies: [
                .product(name: "HexString", package: "hexstring-swift"),
                "SHAKE256"
            ],
            resources: [
                .copy("LongMessages.json"),
                .copy("ShortMessages.json"),
                .copy("VariableOutput.json"),
            ]),
    ]
)
