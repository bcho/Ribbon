// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "Ribbon",
    platforms: [
        .iOS(.v10),
        .macOS(.v10_12),
    ],
    products: [
        .library(
            name: "Ribbon",
            targets: ["Ribbon"]
        ),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "Ribbon",
            dependencies: [],
            path: "Ribbon",
            sources: ["Ribbon/**/*.swift"]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
