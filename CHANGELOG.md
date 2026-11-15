# Changelog

Notable changes to unicornleap. Releases before this file was started are
recorded in the git history and the `v*` tags.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed

- An empty argument (`unicornleap ""`) no longer crashes.
- `-n 0` no longer hangs forever; `-n` and `-s` must be positive.
- Missing values for `-e`, `-u` and `-k` now print an error message.
- Negative numbers are accepted as values (e.g. `-e -0.5`) instead of being
  reported as invalid options.

## [3.0.0] - 2026-11-14

### Added

- Prebuilt universal (Intel + Apple Silicon) macOS binaries attached to GitHub
  releases, built by GitHub Actions.
- `make universal` builds the same universal binary locally.
- `make` builds with `swiftc` directly; Xcode is no longer required to build.
- The default unicorn and sparkle images are embedded in the binary, so
  `~/.unicornleap/` no longer needs to exist. PNGs placed there still override
  the built-in images.

### Changed

- Requires macOS 10.11 or later (Intel) / macOS 11 or later (Apple Silicon).
- Updated for Swift 5.
- Herd mode respects the `-n` flag.
- The unicorn's offset scales with the `-s` speed flag.

### Fixed

- The man page listed the sparkle flag as `-s` instead of `-k`.
- The "valid PNG not found" error now shows the actual path that was tried.
