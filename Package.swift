// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "Intent",
    products: [
        .library(name: "Intent", targets: ["Intent"]),
    ],
    targets: [
        .target(name: "Intent")
    ]
)
