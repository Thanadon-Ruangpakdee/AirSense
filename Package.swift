// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AirSense",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "AirSense",
            targets: ["AirSense"]
        )
    ],
    targets: [
        .executableTarget(
            name: "AirSense",
            path: "AirSense"
        )
    ]
)
