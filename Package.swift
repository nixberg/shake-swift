// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "shake256-swift",
    products: [
        .library(
            name: "SHAKE256",
            targets: ["SHAKE256"]),
    ],
    targets: [
        .target(
            name: "SHAKE256"),
        .testTarget(
            name: "SHAKE256Tests",
            dependencies: ["SHAKE256"],
            resources: [
                .copy("LongMessages.json"),
                .copy("ShortMessages.json"),
                .copy("VariableOutput.json"),
            ]),
    ]
)
