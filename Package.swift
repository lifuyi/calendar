// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "CalendarStatusBar",
    platforms: [.macOS(.v12)],
    products: [
        .executable(name: "CalendarStatusBar", targets: ["CalendarStatusBar"])
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "CalendarStatusBar",
            resources: [
                .process("assets"),
                .process("Media.xcassets")
            ]
        )
    ]
)