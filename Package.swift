// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Tamagomerge",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "Tamagomerge", targets: ["Tamagomerge"])
    ],
    targets: [
        .target(
            name: "Tamagomerge",
            path: "Sources"
        )
    ]
)
