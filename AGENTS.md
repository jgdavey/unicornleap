# AGENTS.md

This file provides guidance to AI coding agents working with code in this repository.

## Overview

`unicornleap` is a macOS command-line tool (Swift 5, macOS 10.15+) that animates a unicorn image leaping across the screen with a sparkle particle trail, using CoreAnimation. The man page is `unicornleap.1`; keep it in sync with the usage text in `main.swift` when flags change.

## Commands

```sh
make              # build with swiftc directly -> build/unicornleap
make universal    # x86_64 (10.15+) + arm64 (11+) universal binary, as shipped in releases
make test         # swift test (Swift Testing; Command Line Tools are enough, no Xcode)
make images       # copy images/*.png to ~/.unicornleap/ (default image location)
make install      # build if needed, install binary and man page under $(DESTDIR)$(PREFIX) (default /usr/local)
make clean
swift run unicornleap -- -n 3   # build and run via SwiftPM
```

Run a single test:

```sh
swift test --filter CommandTests/defaults
```

Neither Xcode nor an Xcode project is needed; `Package.swift` defines the SwiftPM package (open it in Xcode if you want the IDE). The Makefile is what builds the shipped binary; SwiftPM is for `swift test` / `swift run`. Keep the x86_64 target in `make universal` in step with `platforms` in `Package.swift` (macOS 10.15, the minimum for Swift Testing).

The default images are embedded in the binary at link time (`-sectcreate __TEXT __unicorn_png|__sparkle_png`, in both the Makefile and `Package.swift`'s `linkerSettings`), so the built binary runs with no setup. `~/.unicornleap/unicorn.png` / `sparkle.png` override them if present (`make images` copies the defaults there).

## Architecture

- `main.swift` — top-level script: parses `CommandLine.arguments` into a global `command`, dispatches help / version / error / herd / normal mode. Errors and usage-after-an-error go to stderr (via `standardError`) with exit status 1. `leapManyUnicorns` starts one `CATransaction` per unicorn, staggering each by `seconds / 8`, and drives everything with `CFRunLoopRun()`; the completion block of the last transaction calls `CFRunLoopStop` to exit. Herd mode defaults to 30 unicorns and randomizes `command.eccentricity` before each leap (via `setupFunc`), which is why `Command` properties are mutable.
- `Command.swift` — hand-rolled argument parser. Each option has a default and a `parseX()` that returns `nil` when the flag is present but its value is missing/unparseable; `isNotValid` is true if any parsed value is `nil` or an unknown `-` flag is present. When a flag appears in both short and long form, the first occurrence wins. Adding a flag means updating `validFlags`, adding a property + parser, wiring it in `init`, and updating usage text and the man page.
- `Leap.swift` — per-unicorn setup: creates a transparent, click-through, full-screen `FloatingWindow`, loads the unicorn and sparkle images, and attaches their layers/animations.
- `LeapImage.swift` — base class: loads PNG data into a `CGImage` (`loadData` reads the file, falling back to the embedded section via `getsectiondata` only when the path is the default) and adds a `CAKeyframeAnimation` along a path for a configurable key path.
  - `UnicornImage` builds the Bézier leap path (off-screen bottom-left to off-screen bottom-right, peak height scaled by `eccentricity`) and animates `position` of a `CALayer`.
  - `SparkleImage` configures a `CAEmitterLayer` and animates its `emitterPosition` along the unicorn's path.

## Tests

`CommandTests` covers the `Command.swift` parser; `ExitStatusTests` runs the built `unicornleap` binary (next to the test bundle in `.build/`) as a subprocess to check stdout/stderr and exit status (errors go to stderr with exit 1; `-h`/`-V` go to stdout with exit 0); `VersionTests` checks `Version.swift` against `CHANGELOG.md`. Tests use Swift Testing (`import Testing`, `@Test`, `#expect`), not XCTest, because the Command Line Tools ship Swift Testing but not XCTest. `UnicornLeapTests` does `@testable import unicornleap` against the executable target, so new source files need no registration anywhere: SwiftPM and the Makefile both pick up everything in `UnicornLeap/`.

## Releases

Pushing a `vX.Y.Z` tag runs `.github/workflows/release.yml`: it creates a draft GitHub release using that version's `CHANGELOG.md` section (via `scripts/changelog-notes`, which fails the release if there's no section), runs the tests, builds with `make universal`, uploads `unicornleap-X.Y.Z-macos-universal.tar.gz` (binary, man page, README) plus a `.sha256`, then publishes the release. To cut one, rename `## [Unreleased]` in `CHANGELOG.md` to `## [X.Y.Z] - YYYY-MM-DD` and set `version` in `UnicornLeap/Version.swift` to `X.Y.Z` (a test checks it against the newest changelog section, and the release fails if it doesn't match the tag), commit, then tag and push the tag. A tag with anything after `X.Y.Z` (e.g. `v3.0.0.pre`, `v3.0.0-rc.1`) is published as a GitHub prerelease; it still needs its own changelog section. `.github/workflows/ci.yml` builds and tests every branch push and PR.
