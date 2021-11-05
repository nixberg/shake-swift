// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "shake256-swift",
    products: [
        .library(
            name: "SHAKE256",
            targets: ["SHAKE256"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-algorithms", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-collections", from: "1.0.0"),
        .package(url: "https://github.com/nixberg/crypto-traits-swift", from: "0.2.1"),
        .package(url: "https://github.com/nixberg/endianbytes-swift", from: "0.3.0"),
        .package(url: "https://github.com/nixberg/hexstring-swift", from: "0.4.0"),
    ],
    targets: [
        .target(
            name: "SHAKE256",
            dependencies: [
                .product(name: "Algorithms", package: "swift-algorithms"),
                .product(name: "Collections", package: "swift-collections"),
                .product(name: "Duplex", package: "crypto-traits-swift"),
                .product(name: "EndianBytes", package: "endianbytes-swift"),
            ]),
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
