import Foundation

class Command {
  private var arguments = [String]()

  var needsHelp: Bool {
    return arguments.contains("-h") || arguments.contains("--help")
  }

  var isNotValid: Bool {
    let validFlags: Set<String> = ["-h", "--help"]
    let flags = Set(arguments.filter({ $0[$0.startIndex] == "-" }))
    return flags.subtract(validFlags).count != 0
  }

  init(_ arguments: [String]) {
    self.arguments = arguments
  }
}
