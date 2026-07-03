// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "UndiscordApp",
    platforms: [.macOS(.v12)],
    targets: [
        .target(name: "UndiscordCore"),
        .executableTarget(
            name: "UndiscordApp",
            dependencies: ["UndiscordCore"],
            resources: [.copy("undiscord.js")]
        ),
        .testTarget(
            name: "UndiscordCoreTests",
            dependencies: ["UndiscordCore"]
        ),
    ]
)
