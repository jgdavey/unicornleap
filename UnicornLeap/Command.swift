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

  var herd: Bool {
    return arguments.contains("-H") || arguments.contains("--herd")
  }

  var isNotValid: Bool {
    return !invalidFlags.isEmpty || seconds == nil || number == nil || eccentricity == nil || unicornFile == nil || sparkleFile == nil
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
      "-H", "--herd"
    ]
    let flags = Set(arguments.filter({ $0[$0.startIndex] == "-" }))
    return Array(flags.subtracting(validFlags))
  }

  var seconds: Float? = 2.0
  fileprivate func parseSeconds() -> Float? {
    guard let index = flagIndex(["-s", "--seconds"]) else { return seconds }
    return nextArgument(index)?.asFloat
  }

  var number: Int? = 1
  fileprivate func parseNumber() -> Int? {
    guard let index = flagIndex(["-n", "--number"]) else { return number }
    return nextArgument(index)?.asInt
  }

  var passedInNumber: Bool = false
  fileprivate func parsePassedInNumber() -> Bool {
    guard flagIndex(["-n", "--number"]) != nil else { return false }
    return true
  }

  static let defaultImageDir: String = "\(NSHomeDirectory())/.unicornleap/"

  var unicornFile: String? = "\(defaultImageDir)unicorn.png"
  fileprivate func parseUnicornFile() -> String? {
    guard let index = flagIndex(["-u", "--unicorn"]) else { return unicornFile }
    return nextArgument(index)
  }

  var sparkleFile: String? = "\(defaultImageDir)sparkle.png"
  fileprivate func parseSparkleFile() -> String? {
    guard let index = flagIndex(["-k", "--sparkle"]) else { return sparkleFile }
    return nextArgument(index)
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

  var asFloat: Float? {
    return Float(self)
  }
}
