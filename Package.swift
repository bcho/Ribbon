// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "Ribbon",
    platforms: [
.iOS(.v10),
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
            path: "Ribbon"
        ),
    ]
)
