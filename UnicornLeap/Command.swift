import ArgumentParser
import Foundation

// The command-line interface. Each option is declared once here; the help
// text, parsing and errors all come from these declarations. Keep the man page
// (unicornleap.1) in step when an option changes.
struct Command: ParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "unicornleap",
    abstract: "Display a flying unicorn."
  )

  @Option(name: .shortAndLong, help: ArgumentHelp("Animate for n seconds.", valueName: "n"))
  var seconds: Float = 2.0

  @Option(name: .shortAndLong, help: ArgumentHelp(
    "Display i unicorns. (default: 1, or \(Command.defaultHerdNumber) with --herd)", valueName: "i"))
  var number: Int?

  @Flag(name: [.customShort("H"), .long], help: "Enables herd-mode.")
  var herd = false

  // Parsed unconditionally, so a negative value (`-e -0.5`) isn't taken for a flag.
  @Option(name: .shortAndLong, parsing: .unconditional, help: ArgumentHelp(
    "Leap the unicorns with a higher peak.", valueName: "x"))
  var eccentricity: Float = 1.0

  @Option(name: .shortAndLong, help: ArgumentHelp(
    "Filename for unicorn image. (default: ~/.unicornleap/unicorn.png, or the built-in unicorn)", valueName: "file"))
  var unicorn: String?

  @Option(name: [.customShort("k"), .long], help: ArgumentHelp(
    "Filename for sparkle image. (default: ~/.unicornleap/sparkle.png, or the built-in sparkle)", valueName: "file"))
  var sparkle: String?

  @Flag(name: .shortAndLong, help: "Print verbose messages.")
  var verbose = false

  @Flag(name: [.customShort("V"), .long], help: "Print the version and exit.")
  var version = false

  func validate() throws {
    // -V prints the version whatever else is on the command line.
    if version { return }
    // Float parsing accepts "inf", "nan" and overflowing input like "1e40",
    // which would make a leap that never ends or a path with no shape.
    guard seconds.isFinite, seconds > 0 else {
      throw ValidationError("the seconds flag requires a positive number")
    }
    if let number = number, number <= 0 {
      throw ValidationError("the number flag requires a positive integer")
    }
    guard eccentricity.isFinite else {
      throw ValidationError("the eccentricity flag requires a finite number")
    }
  }

  static let defaultImageDir: String = "\(NSHomeDirectory())/.unicornleap/"
  static let defaultUnicornFile: String = "\(defaultImageDir)unicorn.png"
  static let defaultSparkleFile: String = "\(defaultImageDir)sparkle.png"

  var unicornFile: String { unicorn ?? Command.defaultUnicornFile }
  var sparkleFile: String { sparkle ?? Command.defaultSparkleFile }

  // Herd mode leaps this many unicorns unless -n says otherwise.
  static let defaultHerdNumber = 30

  // How many unicorns to leap, after applying the herd-mode default.
  var leapCount: Int { number ?? (herd ? Command.defaultHerdNumber : 1) }

  // Herd mode picks each unicorn's eccentricity from this range.
  static let herdEccentricityRange: Range<Float> = 0..<3
  static func randomHerdEccentricity() -> Float {
    return Float.random(in: herdEccentricityRange)
  }

  // Herd mode gives each unicorn its own random height.
  func eccentricityForNextLeap() -> Float {
    return herd ? Command.randomHerdEccentricity() : eccentricity
  }

  var verboseLines: [String] {
    // A default path that doesn't exist falls back to the embedded image.
    func showImage(_ path: String, defaultPath: String) -> String {
      if path == defaultPath && !FileManager.default.fileExists(atPath: defaultPath) {
        return "built-in"
      }
      return path
    }
    let range = Command.herdEccentricityRange
    var lines = [
      "Seconds: \(seconds)",
      "Number: \(leapCount)",
      "Eccentricity: \(herd ? "random (\(range.lowerBound)..<\(range.upperBound))" : "\(eccentricity)")",
      "Unicorn: \(showImage(unicornFile, defaultPath: Command.defaultUnicornFile))",
      "Sparkle: \(showImage(sparkleFile, defaultPath: Command.defaultSparkleFile))",
    ]
    if herd { lines.append("Herd: on") }
    return lines
  }
}
