// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Redii",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "Redii",
            targets: ["Redii"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Redii",
            dependencies: []
        ),
        .testTarget(
            name: "RediiTests",
            dependencies: ["Redii"]
        )
    ]
)

