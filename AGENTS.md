# AGENTS.md

This file provides guidance to AI coding agents working with code in this repository.

## Overview

`unicornleap` is a macOS command-line tool (Swift 5, macOS 10.11+) that animates a unicorn image leaping across the screen with a sparkle particle trail, using CoreAnimation. The man page is `unicornleap.1`; keep it in sync with the usage text in `main.swift` when flags change.

## Commands

```sh
make              # build with swiftc directly (no Xcode needed) -> build/unicornleap
make universal    # x86_64 (10.11+) + arm64 (11+) universal binary, as shipped in releases
make xcode        # build via xcodebuild instead
make test         # run XCTest suite via xcodebuild (requires full Xcode)
make images       # copy images/*.png to ~/.unicornleap/ (default image location)
make install      # images + copy binary and man page under $PREFIX (default /usr/local)
make clean
```

Run a single test:

```sh
xcodebuild -workspace unicornleap.xcodeproj/project.xcworkspace/ -scheme UnicornLeapTests test \
  -only-testing:UnicornLeapTests/CommandTests/testDefaults
```

Running the built binary requires the default images in `~/.unicornleap/` (run `make images`) or explicit `-u`/`-k` paths.

## Architecture

- `main.swift` — top-level script: parses `CommandLine.arguments` into a global `command`, dispatches help / error / herd / normal mode. `leapManyUnicorns` starts one `CATransaction` per unicorn, staggering each by `seconds / 8`, and drives everything with `CFRunLoopRun()`; the completion block of the last transaction calls `CFRunLoopStop` to exit. Herd mode defaults to 30 unicorns and randomizes `command.eccentricity` before each leap (via `setupFunc`), which is why `Command` properties are mutable.
- `Command.swift` — hand-rolled argument parser. Each option has a default and a `parseX()` that returns `nil` when the flag is present but its value is missing/unparseable; `isNotValid` is true if any parsed value is `nil` or an unknown `-` flag is present. When a flag appears in both short and long form, the first occurrence wins. Adding a flag means updating `validFlags`, adding a property + parser, wiring it in `init`, and updating usage text and the man page.
- `Leap.swift` — per-unicorn setup: creates a transparent, click-through, full-screen `FloatingWindow`, loads the unicorn and sparkle images, and attaches their layers/animations.
- `LeapImage.swift` — base class: loads a PNG into a `CGImage` and adds a `CAKeyframeAnimation` along a path for a configurable key path.
  - `UnicornImage` builds the Bézier leap path (off-screen bottom-left to off-screen bottom-right, peak height scaled by `eccentricity`) and animates `position` of a `CALayer`.
  - `SparkleImage` configures a `CAEmitterLayer` and animates its `emitterPosition` along the unicorn's path.

## Tests

Only `Command.swift` is covered. The `UnicornLeapTests` target compiles `Command.swift` directly into the test bundle (no `@testable import`), so new source files that tests depend on must be added to that target in `project.pbxproj`. The `make` build globs `UnicornLeap/*.swift`, so it doesn't need project changes, but `make xcode` does.

## Releases

Pushing a `vX.Y.Z` tag runs `.github/workflows/release.yml`: it creates a draft GitHub release using that version's `CHANGELOG.md` section (via `scripts/changelog-notes`, which fails the release if there's no section), runs the tests, builds with `make universal`, uploads `unicornleap-X.Y.Z-macos-universal.tar.gz` (binary, man page, README, images) plus a `.sha256`, then publishes the release. To cut one, rename `## [Unreleased]` in `CHANGELOG.md` to `## [X.Y.Z] - YYYY-MM-DD`, commit, then tag and push the tag. `.github/workflows/ci.yml` builds and tests every branch push and PR.
