// swift-tools-version:5.5
import PackageDescription

// `make` / `make universal` build the shipped binary with swiftc directly (see
// the Makefile); this package is for `swift build`, `swift run` and `swift test`.
let package = Package(
  name: "unicornleap",
  platforms: [.macOS(.v10_15)],
  targets: [
    .executableTarget(
      name: "unicornleap",
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
