// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "shake-swift",
    products: [
        .library(
            name: "SHAKE",
            targets: ["SHAKE"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-algorithms",
            .upToNextMajor(from: "1.2.0")),
        .package(
            url: "https://github.com/nixberg/blobby-swift",
            .upToNextMinor(from: "0.2.0")),
        .package(
            url: "https://github.com/nixberg/keccak-p-swift",
            .upToNextMinor(from: "0.1.0")),
    ],
    targets: [
        .target(
            name: "SHAKE",
            dependencies: [
                .product(name: "KeccakP", package: "keccak-p-swift"),
            ]),
        .testTarget(
            name: "SHAKETests",
            dependencies: [
                .product(name: "Algorithms", package: "swift-algorithms"),
                .product(name: "Blobby", package: "blobby-swift"),
                "SHAKE",
            ],
            resources: [
                .process("Blobs"),
            ]),
    ]
)
