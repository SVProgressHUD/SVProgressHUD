// swift-tools-version:5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.
 
import PackageDescription

let package = Package(
    name: "SVProgressHUD",
    platforms: [
        .iOS(.v12),
        .tvOS(.v9)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "SVProgressHUD",
            type: .static,
            targets: ["SVProgressHUD"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "SVProgressHUD",
            dependencies: [],
            path: "SVProgressHUD",
            resources: [
                .process("SVProgressHUD.bundle"),
                .copy("SVProgressHUD-Prefix.pch")
            ]
        )
    ]
)

