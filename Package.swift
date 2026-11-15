// swift-tools-version:5.5
import PackageDescription

// `make` / `make universal` build the shipped binary with this package (see the
// Makefile).
let package = Package(
  name: "unicornleap",
  platforms: [.macOS(.v10_15)],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.8.2"),
  ],
  targets: [
    .executableTarget(
      name: "unicornleap",
      dependencies: [
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
      ],
      path: "UnicornLeap",
      linkerSettings: [
        // Embed the default images in __TEXT (see LeapImage.swift).
        .unsafeFlags([
          "-Xlinker", "-sectcreate", "-Xlinker", "__TEXT", "-Xlinker", "__unicorn_png", "-Xlinker", "images/unicorn.png",
          "-Xlinker", "-sectcreate", "-Xlinker", "__TEXT", "-Xlinker", "__sparkle_png", "-Xlinker", "images/sparkle.png",
        ])
      ]
    ),
    .testTarget(
      name: "UnicornLeapTests",
      dependencies: ["unicornleap"],
      path: "UnicornLeapTests"
    ),
  ]
)
