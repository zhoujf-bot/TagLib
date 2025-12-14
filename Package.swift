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
        )
    ],
    targets: [
        .binaryTarget(
            name: "TagLib",
            path: "TagLib.xcframework"
        ),
        .target(
            name: "TagLibTestSupport",
            dependencies: ["TagLib"],
            path: "Tests/TagLibTestSupport",
            publicHeadersPath: "include"
        ),
        .target(
            name: "TagLibBridge",
            dependencies: ["TagLib"],
            path: "Sources/TagLibBridge",
            publicHeadersPath: "include",
            cxxSettings: [
                .headerSearchPath("include"),
                .define("TAGLIB_CPP", to: "1")
            ]
        ),
        .testTarget(
            name: "TagLibReadWriteTests",
            dependencies: ["TagLibTestSupport"],
            path: "Tests/TagLibReadWriteTests"
        )
    ]
)
