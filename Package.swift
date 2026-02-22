// swift-tools-version: 5.9

import PackageDescription

let package = Package(
  name: "GridSwitch",
  platforms: [
    .macOS(.v14),
  ],
  dependencies: [
    .package(path: "DockBadgeKit"),
  ],
  targets: [
    .executableTarget(
      name: "GridSwitch",
      dependencies: ["DockBadgeKit"],
      path: "Sources/GridSwitch",
      linkerSettings: [
        .linkedFramework("AppKit"),
        .linkedFramework("CoreGraphics"),
        .linkedFramework("ApplicationServices"),
      ]
    ),
  ]
)
