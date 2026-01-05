// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TagLibPackage",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "TagLibPackage",
            targets: ["TagLib"]
        ),
        .library(
            name: "TagLibBridge",
            targets: ["TagLibBridge"]
        ),
        .library(
            name: "MatroskaBridge",
            targets: ["MatroskaBridge"]
        )
    ],
    targets: [
        .binaryTarget(
            name: "TagLib",
            path: "TagLib.xcframework"
        ),
        .target(
            name: "TagLibBridge",
            dependencies: ["TagLib"],
            path: "Sources/TagLibBridge",
            publicHeadersPath: "include",
            cxxSettings: [
                .headerSearchPath("include"),
                .define("TAGLIB_CPP", to: "1")
            ],
            linkerSettings: [
                .linkedLibrary("z")
            ]
        ),
        .target(
            name: "MatroskaBridge",
            dependencies: [],
            path: "Sources/MatroskaBridge",
            publicHeadersPath: "include"
        ),
        .testTarget(
            name: "TagLibReadWriteTests",
            dependencies: ["TagLibBridge"],
            path: "Tests/TagLibReadWriteTests"
        )
    ]
)
