import Foundation

class Command {
  private var arguments = [String]()

  var needsHelp: Bool {
    return arguments.contains("-h") || arguments.contains("--help")
  }

  init(_ arguments: [String]) {
    self.arguments = arguments
  }
}
