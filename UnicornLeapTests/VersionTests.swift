import Foundation
import Testing
@testable import unicornleap

@Suite struct VersionTests {
  // The newest released section in CHANGELOG.md, e.g. "## [3.0.0] - 2026-11-14".
  // Renaming [Unreleased] to cut a release fails this test until Version.swift
  // is bumped to match.
  @Test func matchesLatestChangelogRelease() throws {
    let changelog = URL(fileURLWithPath: #filePath)
      .deletingLastPathComponent().deletingLastPathComponent()
      .appendingPathComponent("CHANGELOG.md")
    let text = try String(contentsOf: changelog, encoding: .utf8)
    let latest = text.components(separatedBy: "\n")
      .first { $0.hasPrefix("## [") && !$0.hasPrefix("## [Unreleased]") }
      .flatMap { $0.dropFirst(4).split(separator: "]").first.map(String.init) }
    #expect(latest == version)
  }
}
