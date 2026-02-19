// swift-tools-version: 5.9

import PackageDescription

let package = Package(
  name: "GridSwitch",
  platforms: [
    .macOS(.v14),
  ],
  targets: [
    .executableTarget(
      name: "GridSwitch",
      path: "Sources/GridSwitch",
      linkerSettings: [
        .linkedFramework("AppKit"),
        .linkedFramework("CoreGraphics"),
        .linkedFramework("ApplicationServices"),
      ]
    ),
  ]
)
