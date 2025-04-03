// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "WeatherApp",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "WeatherApp",
            targets: ["WeatherApp"]),
    ],
    dependencies: [
        // Swift Package Manager dependencies would go here
        // For example:
        // .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.0.0"),
    ],
    targets: [
        .target(
            name: "WeatherApp",
            dependencies: []),
        .testTarget(
            name: "WeatherAppTests",
            dependencies: ["WeatherApp"]),
    ]
)