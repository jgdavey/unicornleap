import Cocoa

func printUsage(exitCode: Int32) {
  print(
    "Usage: unicornleap [options]\n",
    "  -h  --help           Display this usage information.\n",
    "  -s  --seconds n      Animate for n seconds. (default: 2.0)\n",
    "  -n  --number i       Display i unicorns. (default: 1)\n",
    "  -u  --unicorn file   Filename to use for unicorn image.\n",
    "  -k  --sparkle file   Filename to use for sparkle image.\n",
    "  -v  --verbose        Print verbose messages."
  )

  exit(exitCode)
}

func printCommandErrors(command: Command) {
  var errors = [String]()

  if !command.invalidFlags.isEmpty {
    let invalidOptions = command.invalidFlags.joinWithSeparator(", ")
    errors.append("unicornleap - invalid options: \(invalidOptions)")
  }

  if command.seconds == nil {
    errors.append("unicornleap - the seconds flag requires an argument")
  }

  if command.number == nil {
    errors.append("unicornleap - the number flag requires an argument")
  }

  print("\(errors.joinWithSeparator("\n"))\n")
}

func printImageError(filename: String) {
  print("unicornleap - valid PNG not found: ~/.unicornleap/\(filename)")
  exit(127)
}

let command = Command(Process.arguments)

if command.needsHelp {
  printUsage(0)
} else if command.isNotValid {
  printCommandErrors(command)
  printUsage(1)
} else {
  Leap.animateImage(command)
}
