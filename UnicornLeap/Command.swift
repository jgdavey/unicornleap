import Foundation

class Command {
  fileprivate var arguments = [String]()

  fileprivate func nextArgument(_ index: Int) -> String? {
    let nextIndex = index.advanced(by: 1)
    guard nextIndex < arguments.count else { return nil }
    return arguments[nextIndex]
  }

  fileprivate func flagIndex(_ flags: [String]) -> Int? {
    let indexes = flags.map { arguments.firstIndex(of: $0) }
    return indexes.compactMap({$0}).first
  }

  var needsHelp: Bool {
    return arguments.contains("-h") || arguments.contains("--help")
  }

  var verboseOutput: Bool {
    return arguments.contains("-v") || arguments.contains("--verbose")
  }

  var wantsVersion: Bool {
    return arguments.contains("-V") || arguments.contains("--version")
  }

  var verboseLines: [String] {
    func show<T>(_ value: T?) -> String { value.map { "\($0)" } ?? "invalid" }
    // A default path that doesn't exist falls back to the embedded image.
    func showImage(_ path: String?, defaultPath: String) -> String {
      if path == defaultPath && !FileManager.default.fileExists(atPath: defaultPath) {
        return "built-in"
      }
      return show(path)
    }
    let range = Command.herdEccentricityRange
    var lines = [
      "Seconds: \(show(seconds))",
      "Number: \(show(leapCount))",
      "Eccentricity: \(herd ? "random (\(range.lowerBound)..<\(range.upperBound))" : show(eccentricity))",
      "Unicorn: \(showImage(unicornFile, defaultPath: Command.defaultUnicornFile))",
      "Sparkle: \(showImage(sparkleFile, defaultPath: Command.defaultSparkleFile))",
    ]
    if herd { lines.append("Herd: on") }
    return lines
  }

  var herd: Bool {
    return arguments.contains("-H") || arguments.contains("--herd")
  }

  var isNotValid: Bool {
    return !errors.isEmpty
  }

  var errors: [String] {
    var errors = [String]()
    if !invalidFlags.isEmpty {
      errors.append("invalid options: \(invalidFlags.joined(separator: ", "))")
    }
    if seconds == nil { errors.append("the seconds flag requires a positive number") }
    if number == nil { errors.append("the number flag requires a positive integer") }
    if eccentricity == nil { errors.append("the eccentricity flag requires a number") }
    if unicornFile == nil { errors.append("the unicorn flag requires a filename") }
    if sparkleFile == nil { errors.append("the sparkle flag requires a filename") }
    return errors.map { "unicornleap - \($0)" }
  }

  var invalidFlags: [String] {
    let validFlags: Set<String> = [
      "-h", "--help",
      "-s", "--seconds",
      "-n", "--number",
      "-u", "--unicorn",
      "-k", "--sparkle",
      "-v", "--verbose",
      "-e", "--eccentricity",
      "-H", "--herd",
      "-V", "--version"
    ]
    // Negative numbers ("-1", "-0.5") are values, not flags.
    let flags = Set(arguments.filter({ $0.hasPrefix("-") && $0.asFloat == nil }))
    return Array(flags.subtracting(validFlags))
  }

  var seconds: Float? = 2.0
  fileprivate func parseSeconds() -> Float? {
    guard let index = flagIndex(["-s", "--seconds"]) else { return seconds }
    return nextArgument(index)?.asFloat.flatMap { $0 > 0 ? $0 : nil }
  }

  var number: Int? = 1
  fileprivate func parseNumber() -> Int? {
    guard let index = flagIndex(["-n", "--number"]) else { return number }
    return nextArgument(index)?.asInt.flatMap { $0 > 0 ? $0 : nil }
  }

  var passedInNumber: Bool = false
  fileprivate func parsePassedInNumber() -> Bool {
    guard flagIndex(["-n", "--number"]) != nil else { return false }
    return true
  }

  // Herd mode leaps this many unicorns unless -n says otherwise.
  static let defaultHerdNumber = 30

  // How many unicorns to leap, after applying the herd-mode default.
  var leapCount: Int? {
    return herd && !passedInNumber ? Command.defaultHerdNumber : number
  }

  static let defaultImageDir: String = "\(NSHomeDirectory())/.unicornleap/"
  static let defaultUnicornFile: String = "\(defaultImageDir)unicorn.png"
  static let defaultSparkleFile: String = "\(defaultImageDir)sparkle.png"

  var unicornFile: String? = defaultUnicornFile
  fileprivate func parseUnicornFile() -> String? {
    guard let index = flagIndex(["-u", "--unicorn"]) else { return unicornFile }
    return nextArgument(index)
  }

  var sparkleFile: String? = defaultSparkleFile
  fileprivate func parseSparkleFile() -> String? {
    guard let index = flagIndex(["-k", "--sparkle"]) else { return sparkleFile }
    return nextArgument(index)
  }

  // Herd mode picks each unicorn's eccentricity from this range.
  static let herdEccentricityRange: Range<Float> = 0..<3
  static func randomHerdEccentricity() -> Float {
    return Float.random(in: herdEccentricityRange)
  }

  var eccentricity: Float? = 1.0
  fileprivate func parseEccentricity() -> Float? {
    guard let index = flagIndex(["-e", "--eccentricity"]) else { return eccentricity }
    return nextArgument(index)?.asFloat
  }

  init(_ arguments: [String]) {
    self.arguments = arguments
    self.seconds = parseSeconds()
    self.number = parseNumber()
    self.passedInNumber = parsePassedInNumber()
    self.unicornFile = parseUnicornFile()
    self.sparkleFile = parseSparkleFile()
    self.eccentricity = parseEccentricity()
  }
}

private extension String {
  var asInt: Int? {
    return Int(self)
  }

  // Only finite values: "inf", "nan" and overflowing input like "1e40" parse
  // as Float but would make a leap that never ends or a path with no shape.
  var asFloat: Float? {
    return Float(self).flatMap { $0.isFinite ? $0 : nil }
  }
}
