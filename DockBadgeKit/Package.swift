// swift-tools-version: 5.9

import PackageDescription

let package = Package(
  name: "DockBadgeKit",
  platforms: [
    .macOS(.v14),
  ],
  products: [
    .library(
      name: "DockBadgeKit",
      targets: ["DockBadgeKit"]
    ),
  ],
  targets: [
    .target(
      name: "DockBadgeKit",
      path: "Sources/DockBadgeKit",
      linkerSettings: [
        .linkedFramework("AppKit"),
        .linkedFramework("ApplicationServices"),
      ]
    ),
    .testTarget(
      name: "DockBadgeKitTests",
      dependencies: ["DockBadgeKit"],
      path: "Tests/DockBadgeKitTests"
    ),
  ]
)
