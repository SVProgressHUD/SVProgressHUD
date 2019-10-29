// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SVProgressHUD",
    platforms: [
        .iOS(.v8),
        .tvOS(.v9)
    ],
    products: [
        .library(
            name: "SVProgressHUD",
            targets: ["SVProgressHUD"]
        )
    ],
    targets: [
        .target(
            name: "SVProgressHUD",
            path: "SVProgressHUD",
            exclude: [
                "SVProgressHUD-Framework",
                "Demo"
            ]
        ),
    ],
    swiftLanguageVersions: [.v5]
)

let version = Version(2, 2, 6)
