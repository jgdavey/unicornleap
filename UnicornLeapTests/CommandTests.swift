import Foundation
import Testing
@testable import unicornleap

@Suite struct CommandTests {
  @Test func defaults() {
    let command = Command([])

    #expect(!command.needsHelp)
    #expect(!command.isNotValid)
    #expect(!command.verboseOutput)
    #expect(command.seconds == 2.0)
    #expect(command.number == 1)
    #expect(command.eccentricity == 1.0)
    #expect(command.unicornFile?.hasSuffix("unicorn.png") == true)
    #expect(command.sparkleFile?.hasSuffix("sparkle.png") == true)
  }

  @Test(arguments: ["-h", "--help"])
  func needsHelp(flag: String) {
    let command = Command([flag])
    #expect(!command.isNotValid)
    #expect(command.needsHelp)
  }

  @Test(arguments: ["-v", "--verbose"])
  func wantsVerboseOutput(flag: String) {
    let command = Command([flag])
    #expect(!command.isNotValid)
    #expect(command.verboseOutput)
  }

  @Test func verboseLinesShowPlainValues() {
    let command = Command(["-v", "-s", "3.5", "-n", "4", "-e", "2", "-u", "u.png", "-k", "k.png"])
    #expect(command.verboseLines == [
      "Seconds: 3.5", "Number: 4", "Eccentricity: 2.0", "Unicorn: u.png", "Sparkle: k.png",
    ])
  }

  @Test func verboseLinesInHerdMode() {
    let command = Command(["-v", "-H", "-u", "u.png", "-k", "k.png"])
    #expect(command.verboseLines == [
      "Seconds: 2.0", "Number: 30", "Eccentricity: random (0.0..<3.0)",
      "Unicorn: u.png", "Sparkle: k.png", "Herd: on",
    ])
  }

  @Test func verboseLinesNameTheBuiltInImages() {
    // The default paths fall back to the embedded images when missing.
    let command = Command([])
    let unicornExists = FileManager.default.fileExists(atPath: Command.defaultUnicornFile)
    let line = command.verboseLines.first { $0.hasPrefix("Unicorn: ") }
    #expect(line == (unicornExists ? "Unicorn: \(Command.defaultUnicornFile)" : "Unicorn: built-in"))
  }

  @Test func herdNumberDefaultsToThirty() {
    #expect(Command(["-H"]).leapCount == 30)
    #expect(Command(["-H", "-n", "3"]).leapCount == 3)
    #expect(Command([]).leapCount == 1)
    #expect(Command(["-n", "4"]).leapCount == 4)
  }

  @Test(arguments: ["-H", "--herd"])
  func wantsHerdMode(flag: String) {
    let command = Command([flag])
    #expect(!command.isNotValid)
    #expect(command.herd)
  }

  @Test(arguments: ["-V", "--version"])
  func wantsVersion(flag: String) {
    let command = Command([flag])
    #expect(!command.isNotValid)
    #expect(command.wantsVersion)
  }

  @Test func doesNotWantVersionByDefault() {
    #expect(!Command([]).wantsVersion)
  }

  @Test(arguments: ["-i", "--invalid"])
  func hasInvalidFlags(flag: String) {
    let command = Command([flag])
    #expect(command.isNotValid)
    #expect(command.invalidFlags == [flag])
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

  @Test(arguments: ["-s", "--seconds"])
  func providingSeconds(flag: String) {
    let command = Command([flag, "5"])
    #expect(!command.isNotValid)
    #expect(command.seconds == 5.0)
  }

  @Test(arguments: ["-s", "--seconds"])
  func providingSecondsWithoutAValue(flag: String) {
    let command = Command([flag])
    #expect(command.isNotValid)
    #expect(command.seconds == nil)
  }

  @Test(arguments: ["-s", "--seconds"])
  func providingSecondsWithBadValue(flag: String) {
    let command = Command([flag, "four"])
    #expect(command.isNotValid)
    #expect(command.seconds == nil)
  }

  @Test func providingShortAndLongSeconds() {
    let command = Command(["-s", "5", "--seconds", "6"])
    #expect(!command.isNotValid)
    #expect(command.seconds == 5)
  }

  @Test(arguments: ["0", "-1"])
  func secondsMustBePositive(value: String) {
    let command = Command(["-s", value])
    #expect(command.isNotValid)
    #expect(command.seconds == nil)
  }

  // An infinite duration would never finish, so the run loop would never stop.
  @Test(arguments: ["inf", "infinity", "nan", "1e40"])
  func secondsMustBeFinite(value: String) {
    let command = Command(["-s", value])
    #expect(command.isNotValid)
    #expect(command.seconds == nil)
  }

  // MARK: eccentricity

  @Test(arguments: ["-e", "--eccentricity"])
  func providingEccentricity(flag: String) {
    let command = Command([flag, "5"])
    #expect(!command.isNotValid)
    #expect(command.eccentricity == 5.0)
  }

  @Test(arguments: ["-e", "--eccentricity"])
  func providingEccentricityWithoutAValue(flag: String) {
    let command = Command([flag])
    #expect(command.isNotValid)
    #expect(command.eccentricity == nil)
  }

  @Test(arguments: ["-e", "--eccentricity"])
  func providingEccentricityWithBadValue(flag: String) {
    let command = Command([flag, "four"])
    #expect(command.isNotValid)
    #expect(command.eccentricity == nil)
  }

  @Test(arguments: ["inf", "-inf", "nan", "1e40"])
  func eccentricityMustBeFinite(value: String) {
    let command = Command(["-e", value])
    #expect(command.isNotValid)
    #expect(command.eccentricity == nil)
  }

  @Test func providingShortAndLongEccentricity() {
    let command = Command(["-e", "5", "--eccentricity", "6"])
    #expect(!command.isNotValid)
    #expect(command.eccentricity == 5)
  }

  @Test func negativeNumberValuesAreNotFlags() {
    let command = Command(["-e", "-0.5"])
    #expect(command.invalidFlags == [])
    #expect(!command.isNotValid)
    #expect(command.eccentricity == -0.5)
  }

  // MARK: number

  @Test(arguments: ["-n", "--number"])
  func providingNumber(flag: String) {
    let command = Command([flag, "5"])
    #expect(!command.isNotValid)
    #expect(command.number == 5)
  }

  @Test(arguments: ["-n", "--number"])
  func providingNumberWithoutAValue(flag: String) {
    let command = Command([flag])
    #expect(command.isNotValid)
    #expect(command.number == nil)
  }

  @Test(arguments: ["-n", "--number"])
  func providingNumberWithBadValue(flag: String) {
    let command = Command([flag, "four"])
    #expect(command.isNotValid)
    #expect(command.number == nil)
  }

  @Test func providingShortAndLongNumber() {
    let command = Command(["-n", "5", "--number", "6"])
    #expect(!command.isNotValid)
    #expect(command.number == 5)
  }

  @Test(arguments: ["0", "-1"])
  func numberMustBePositive(value: String) {
    let command = Command(["-n", value])
    #expect(command.isNotValid)
    #expect(command.number == nil)
  }

  // MARK: image files

  @Test(arguments: ["-u", "--unicorn"])
  func providingUnicornFile(flag: String) {
    let command = Command([flag, "hippo.png"])
    #expect(!command.isNotValid)
    #expect(command.unicornFile == "hippo.png")
  }

  @Test(arguments: ["-u", "--unicorn"])
  func providingUnicornFileWithoutAValue(flag: String) {
    let command = Command([flag])
    #expect(command.isNotValid)
    #expect(command.unicornFile == nil)
  }

  @Test func providingShortAndLongUnicornFile() {
    let command = Command(["-u", "hippo.png", "--unicorn", "bat.png"])
    #expect(!command.isNotValid)
    #expect(command.unicornFile == "hippo.png")
  }

  @Test(arguments: ["-k", "--sparkle"])
  func providingSparkleFile(flag: String) {
    let command = Command([flag, "poof.png"])
    #expect(!command.isNotValid)
    #expect(command.sparkleFile == "poof.png")
  }

  @Test(arguments: ["-k", "--sparkle"])
  func providingSparkleFileWithoutAValue(flag: String) {
    let command = Command([flag])
    #expect(command.isNotValid)
    #expect(command.sparkleFile == nil)
  }

  @Test func providingShortAndLongSparkleFile() {
    let command = Command(["-k", "poof.png", "--sparkle", "blood.png"])
    #expect(!command.isNotValid)
    #expect(command.sparkleFile == "poof.png")
  }

  // MARK: errors

  @Test func emptyArgumentIsNotAFlag() {
    #expect(Command([""]).invalidFlags == [])
  }

  @Test func noErrorsForValidCommand() {
    #expect(Command(["-s", "3", "-n", "2"]).errors == [])
  }

  @Test(arguments: [
    ("-s", "seconds"), ("-n", "number"), ("-e", "eccentricity"),
    ("-u", "unicorn"), ("-k", "sparkle"),
  ])
  func errorsNameEachFlagMissingAValue(flag: String, name: String) {
    let errors = Command([flag]).errors
    #expect(errors.count == 1)
    #expect(errors.first?.contains("the \(name) flag") == true)
  }

  @Test func errorsListInvalidFlags() {
    #expect(Command(["-i"]).errors == ["unicornleap - invalid options: -i"])
  }
}
