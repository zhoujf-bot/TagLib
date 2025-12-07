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
        )
    ],
    targets: [
        .binaryTarget(
            name: "TagLib",
            path: "TagLib.xcframework"
        )
    ]
)
