// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "UndiscordApp",
    platforms: [.macOS(.v12)],
    targets: [
        .executableTarget(
            name: "UndiscordApp",
            resources: [.copy("undiscord.js")]
        )
    ]
)
