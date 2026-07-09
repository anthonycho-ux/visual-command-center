// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "visual-command-center",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "VisualCommandCenter", targets: ["VisualCommandCenter"])
    ],
    targets: [
        .executableTarget(name: "VisualCommandCenter")
    ]
)
