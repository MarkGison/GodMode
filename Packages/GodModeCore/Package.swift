// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "GodModeCore",
    platforms: [.iOS("26.0"), .macOS(.v15)],
    products: [.library(name: "GodModeCore", targets: ["GodModeCore"])],
    targets: [
        .target(name: "GodModeCore", resources: [.process("Resources")]),
        .testTarget(name: "GodModeCoreTests", dependencies: ["GodModeCore"])
    ]
)
