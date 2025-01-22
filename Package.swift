// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "StemDiffer",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(
            name: "StemDiffer",
            targets: ["StemDiffer"]
        )
    ],
    targets: [
        .executableTarget(
            name: "StemDiffer",
            dependencies: [],
            path: "Sources/StemDiffer",
            swiftSettings: [
                .unsafeFlags(["-framework", "AppKit"]),
                .define("DEBUG")
            ],
            linkerSettings: [
                .linkedFramework("AppKit")
            ]
        )
    ]
) 