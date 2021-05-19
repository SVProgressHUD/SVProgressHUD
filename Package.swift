// swift-tools-version:5.4
import PackageDescription

let package = Package(
  name: "SVProgressHUD",
  platforms: [
    .iOS(.v9), .tvOS(.v9)
  ],
  products: [
    .library(name: "SVProgressHUD", targets: ["SVProgressHUD"])
  ],
  targets: [
    .target(
      name: "SVProgressHUD",
      path: "SVProgressHUD",
      exclude: ["SVProgressHUD-Prefix.pch"],
      resources: [.copy("SVProgressHUD.bundle")],
      publicHeadersPath: "include")
  ]
)
