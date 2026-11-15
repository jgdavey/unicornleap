import Foundation
import Testing
@testable import unicornleap

/// The error message parsing `arguments` fails with, or nil if it succeeds.
private func errorMessage(_ arguments: [String]) -> String? {
  do {
    _ = try Command.parse(arguments)
    return nil
  } catch {
    return Command.message(for: error)
  }
}

@Suite struct CommandTests {
  @Test func defaults() throws {
    let command = try Command.parse([])

    #expect(!command.verbose)
    #expect(!command.herd)
    #expect(!command.version)
    #expect(command.seconds == 2.0)
    #expect(command.leapCount == 1)
    #expect(command.eccentricity == 1.0)
    #expect(command.unicornFile == Command.defaultUnicornFile)
    #expect(command.sparkleFile == Command.defaultSparkleFile)
    #expect(command.unicornFile.hasSuffix("/.unicornleap/unicorn.png"))
    #expect(command.sparkleFile.hasSuffix("/.unicornleap/sparkle.png"))
  }

  @Test(arguments: ["-v", "--verbose"])
  func wantsVerboseOutput(flag: String) throws {
    #expect(try Command.parse([flag]).verbose)
  }

  @Test(arguments: ["-H", "--herd"])
  func wantsHerdMode(flag: String) throws {
    #expect(try Command.parse([flag]).herd)
  }

  @Test(arguments: ["-V", "--version"])
  func wantsVersion(flag: String) throws {
    #expect(try Command.parse([flag]).version)
  }

  // -V wins over anything else, as it did with the old parser.
  @Test func versionSkipsValidation() throws {
    #expect(try Command.parse(["-V", "-s", "0"]).version)
  }

  @Test func groupedShortFlags() throws {
    let command = try Command.parse(["-Hv"])
    #expect(command.herd)
    #expect(command.verbose)
  }

  @Test func helpIsAvailable() {
    let help = Command.helpMessage()
    for flag in ["-s, --seconds", "-n, --number", "-H, --herd", "-e, --eccentricity",
                 "-u, --unicorn", "-k, --sparkle", "-v, --verbose", "-V, --version", "-h, --help"] {
      #expect(help.contains(flag), "\(flag) is missing from the help")
    }
  }

  // MARK: verbose output

  @Test func verboseLinesShowPlainValues() throws {
    let command = try Command.parse(["-v", "-s", "3.5", "-n", "4", "-e", "2", "-u", "u.png", "-k", "k.png"])
    #expect(command.verboseLines == [
      "Seconds: 3.5", "Number: 4", "Eccentricity: 2.0", "Unicorn: u.png", "Sparkle: k.png",
    ])
  }

  @Test func verboseLinesInHerdMode() throws {
    let command = try Command.parse(["-v", "-H", "-u", "u.png", "-k", "k.png"])
    #expect(command.verboseLines == [
      "Seconds: 2.0", "Number: 30", "Eccentricity: random (0.0..<3.0)",
      "Unicorn: u.png", "Sparkle: k.png", "Herd: on",
    ])
  }

  @Test func verboseLinesNameTheBuiltInImages() throws {
    // The default paths fall back to the embedded images when missing.
    let command = try Command.parse([])
    let unicornExists = FileManager.default.fileExists(atPath: Command.defaultUnicornFile)
    let line = command.verboseLines.first { $0.hasPrefix("Unicorn: ") }
    #expect(line == (unicornExists ? "Unicorn: \(Command.defaultUnicornFile)" : "Unicorn: built-in"))
  }

  // MARK: herd

  @Test func herdNumberDefaultsToThirty() throws {
    #expect(try Command.parse(["-H"]).leapCount == 30)
    #expect(try Command.parse(["-H", "-n", "3"]).leapCount == 3)
    #expect(try Command.parse([]).leapCount == 1)
    #expect(try Command.parse(["-n", "4"]).leapCount == 4)
  }

  @Test func eccentricityForNextLeap() throws {
    let normal = try Command.parse(["-e", "2.5"])
    #expect((0..<20).allSatisfy { _ in normal.eccentricityForNextLeap() == 2.5 })

    let herd = try Command.parse(["-H"])
    let samples = (0..<200).map { _ in herd.eccentricityForNextLeap() }
    #expect(samples.allSatisfy { Command.herdEccentricityRange.contains($0) })
    #expect(Set(samples).count > 1)
  }

  // Herd heights must not depend on -n: with the old `random(0..<n) / 10`,
  // `-H -n 1` always leapt flat (eccentricity 0).
  @Test func herdEccentricityCoversTheFullRange() {
    let samples = (0..<500).map { _ in Command.randomHerdEccentricity() }
    #expect(samples.allSatisfy { Command.herdEccentricityRange.contains($0) })
    #expect(samples.max()! > 2)
    #expect(samples.min()! < 1)
  }

  // MARK: seconds

  @Test(arguments: [["-s", "5"], ["--seconds", "5"], ["--seconds=5"]])
  func providingSeconds(arguments: [String]) throws {
    #expect(try Command.parse(arguments).seconds == 5.0)
  }

  @Test(arguments: ["-s", "--seconds"])
  func providingSecondsWithoutAValue(flag: String) {
    #expect(errorMessage([flag])?.contains("Missing value") == true)
  }

  @Test(arguments: ["-s", "--seconds"])
  func providingSecondsWithBadValue(flag: String) {
    #expect(errorMessage([flag, "four"])?.contains("four") == true)
  }

  // The last occurrence wins, as is usual for command-line tools.
  @Test func providingShortAndLongSeconds() throws {
    #expect(try Command.parse(["-s", "5", "--seconds", "6"]).seconds == 6)
  }

  // An infinite duration would never finish, so the run loop would never stop.
  @Test(arguments: ["0", "inf", "infinity", "nan", "1e40"])
  func secondsMustBePositiveAndFinite(value: String) {
    #expect(errorMessage(["-s", value]) == "the seconds flag requires a positive number")
  }

  @Test func negativeSecondsAreRejected() {
    #expect(errorMessage(["-s", "-1"]) != nil)
  }

  // MARK: eccentricity

  @Test(arguments: [["-e", "5"], ["--eccentricity", "5"], ["--eccentricity=5"]])
  func providingEccentricity(arguments: [String]) throws {
    #expect(try Command.parse(arguments).eccentricity == 5.0)
  }

  @Test(arguments: ["-e", "--eccentricity"])
  func providingEccentricityWithoutAValue(flag: String) {
    #expect(errorMessage([flag])?.contains("Missing value") == true)
  }

  @Test(arguments: ["-e", "--eccentricity"])
  func providingEccentricityWithBadValue(flag: String) {
    #expect(errorMessage([flag, "four"])?.contains("four") == true)
  }

  @Test(arguments: ["inf", "-inf", "nan", "1e40"])
  func eccentricityMustBeFinite(value: String) {
    #expect(errorMessage(["-e", value]) == "the eccentricity flag requires a finite number")
  }

  @Test(arguments: [["-e", "-0.5"], ["--eccentricity", "-0.5"], ["-e", "-1", "-v"]])
  func negativeEccentricityIsAValueNotAFlag(arguments: [String]) throws {
    #expect(try Command.parse(arguments).eccentricity == Float(arguments[1]))
  }

  // MARK: number

  @Test(arguments: [["-n", "5"], ["--number", "5"], ["--number=5"]])
  func providingNumber(arguments: [String]) throws {
    #expect(try Command.parse(arguments).leapCount == 5)
  }

  @Test(arguments: ["-n", "--number"])
  func providingNumberWithoutAValue(flag: String) {
    #expect(errorMessage([flag])?.contains("Missing value") == true)
  }

  @Test(arguments: ["four", "2.5"])
  func providingNumberWithBadValue(value: String) {
    #expect(errorMessage(["-n", value])?.contains(value) == true)
  }

  @Test func numberMustBePositive() {
    #expect(errorMessage(["-n", "0"]) == "the number flag requires a positive integer")
    #expect(errorMessage(["-n", "-1"]) != nil)
  }

  // MARK: image files

  @Test(arguments: [["-u", "hippo.png"], ["--unicorn", "hippo.png"], ["--unicorn=hippo.png"]])
  func providingUnicornFile(arguments: [String]) throws {
    #expect(try Command.parse(arguments).unicornFile == "hippo.png")
  }

  @Test(arguments: [["-k", "poof.png"], ["--sparkle", "poof.png"], ["--sparkle=poof.png"]])
  func providingSparkleFile(arguments: [String]) throws {
    #expect(try Command.parse(arguments).sparkleFile == "poof.png")
  }

  @Test(arguments: ["-u", "--unicorn", "-k", "--sparkle"])
  func providingImageFileWithoutAValue(flag: String) {
    #expect(errorMessage([flag])?.contains("Missing value") == true)
  }

  // MARK: errors

  @Test(arguments: ["-i", "--invalid"])
  func rejectsUnknownFlags(flag: String) {
    #expect(errorMessage([flag]) == "Unknown option '\(flag)'")
  }

  @Test func rejectsStrayArguments() {
    #expect(errorMessage(["unicorn"]) != nil)
  }
}
