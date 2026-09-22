// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "GPSsquared",
    products: [
        // 🌟 ONLY expose the library target to external users
        .library(
            name: "GPSsquared",
            targets: ["GPSsquared"]),
    ],
    targets: [
        // Core framework library (Shared across all platforms)
        .target(
            name: "GPSsquared",
            dependencies: []),
        
        // 🔒 Internal CLI tool for your local testing (Ignored by external apps)
        .executableTarget(
            name: "GPSsquared_terminal",
            dependencies: ["GPSsquared"]),
        
        // 🧪 Comprehensive unit test suites
        .testTarget(
            name: "GPSsquaredTests",
            dependencies: ["GPSsquared"]),
    ]
)
