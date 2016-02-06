import Foundation

class Command {
  private var arguments = [String]()

  private func nextArgument(index: Int) -> String? {
    let nextIndex = index.advancedBy(1)
    guard nextIndex < arguments.count else { return nil }
    return arguments[nextIndex]
  }

  private func flagIndex(flags: [String]) -> Int? {
    let indexes = flags.map { arguments.indexOf($0) }
    return indexes.flatMap({$0}).first
  }

  let unicornFile = "unicorn.png"
  let sparkleFile = "sparkle.png"

  var needsHelp: Bool {
    return arguments.contains("-h") || arguments.contains("--help")
  }

  var isNotValid: Bool {
    return !invalidFlags.isEmpty || seconds == nil || number == nil
  }

  var invalidFlags: [String] {
    let validFlags: Set<String> = ["-h", "--help", "-s", "--seconds", "-n", "--number"]
    let flags = Set(arguments.filter({ $0[$0.startIndex] == "-" }))
    return Array(flags.subtract(validFlags))
  }

  var seconds: Float? {
    guard let index = flagIndex(["-s", "--seconds"]) else { return 2.0 }
    return nextArgument(index)?.asFloat
  }

  var number: Int? {
    guard let index = flagIndex(["-n", "--number"]) else { return 1 }
    return nextArgument(index)?.asInt
  }

  init(_ arguments: [String]) {
    self.arguments = arguments
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
