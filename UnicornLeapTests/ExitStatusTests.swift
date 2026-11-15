import Foundation
import Testing

/// Runs the built `unicornleap` executable, which SwiftPM puts next to the test bundle.
private func run(_ arguments: [String]) throws -> (status: Int32, stdout: String, stderr: String) {
  final class Anchor {}
  let binary = Bundle(for: Anchor.self).bundleURL
    .deletingLastPathComponent().appendingPathComponent("unicornleap")
  let process = Process()
  process.executableURL = binary
  process.arguments = arguments
  let stdout = Pipe(), stderr = Pipe()
  process.standardOutput = stdout
  process.standardError = stderr
  try process.run()
  let out = stdout.fileHandleForReading.readDataToEndOfFile()
  let err = stderr.fileHandleForReading.readDataToEndOfFile()
  process.waitUntilExit()
  return (process.terminationStatus, String(decoding: out, as: UTF8.self), String(decoding: err, as: UTF8.self))
}

@Suite struct ExitStatusTests {
  @Test func helpGoesToStdout() throws {
    let result = try run(["-h"])
    #expect(result.status == 0)
    #expect(result.stdout.contains("Usage: unicornleap"))
    #expect(result.stderr.isEmpty)
  }

  @Test func versionGoesToStdout() throws {
    let result = try run(["--version"])
    #expect(result.status == 0)
    #expect(result.stdout.hasPrefix("unicornleap "))
    #expect(result.stderr.isEmpty)
  }

  @Test func invalidOptionsGoToStderr() throws {
    let result = try run(["-x"])
    #expect(result.status == 1)
    #expect(result.stdout.isEmpty)
    #expect(result.stderr.contains("unicornleap - invalid options: -x"))
    #expect(result.stderr.contains("Usage: unicornleap"))
  }

  @Test func missingImageGoesToStderr() throws {
    let result = try run(["-u", "/nonexistent/unicorn.png"])
    #expect(result.status == 1)
    #expect(result.stdout.isEmpty)
    #expect(result.stderr.contains("valid PNG not found: /nonexistent/unicorn.png"))
  }
}
