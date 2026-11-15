# Changelog

Notable changes to unicornleap. Releases before this file was started are
recorded in the git history and the `v*` tags.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- `-v` also prints the eccentricity, the unicorn and sparkle images (or
  `built-in` for the embedded defaults), and whether herd mode is on.

### Fixed

- Unicorns now leap over full-screen apps and on whichever Space is active,
  instead of only on regular desktop Spaces.
- `-s` and `-e` reject values that aren't finite numbers (`inf`, `nan`,
  `1e40`). They used to be accepted and silently showed no unicorn.
- `make install` rebuilds when a source file or default image has changed,
  instead of installing whatever binary was already in `build/`.
- `-v` works in herd mode; it used to print nothing with `-H`.

## [3.1.0] - 2026-11-14

### Added

- `-V` / `--version` prints the version.

### Changed

- The Xcode project is replaced by a SwiftPM `Package.swift`. `make test` runs
  `swift test`, which works with only the Command Line Tools installed.
- `make install` builds first if needed, creates the target directories, and
  honors `DESTDIR`.
- Error messages (and the usage text shown after an error) go to stderr
  instead of stdout. A missing or invalid image exits with status 1 instead
  of 127.
- Requires macOS 10.15 or later on Intel (was 10.11). Apple Silicon still
  requires macOS 11.

### Fixed

- Herd mode's leap heights no longer depend on `-n`; `-H -n 1` used to leap
  flat along the bottom of the screen.
- `-v` prints plain values (`Seconds: 2.0`) instead of `Seconds: Optional(2.0)`.
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
