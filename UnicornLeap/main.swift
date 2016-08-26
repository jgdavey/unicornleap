import Cocoa

func printUsage(exitCode: Int32) {
  print(
    "Usage: unicornleap [options]\n",
    "  -h  --help           Display usage information.\n",
    "  -s  --seconds n      Animate for n seconds. (default: 2.0)\n",
    "  -n  --number i       Display i unicorns. (default: 1)\n",
    "  -u  --unicorn file   Filename for unicorn image.\n",
    "  -k  --sparkle file   Filename for sparkle image.\n",
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

func printVerboseOutput() {
  print("Seconds: \(command.seconds)")
  print("Number: \(command.number)")
}

func leapThoseUnicorns() {
  let startTime = CACurrentMediaTime()
  for i in (0..<command.number!) {
    CATransaction.begin()
    CATransaction.setCompletionBlock({
      if (i + 1 == command.number!) {
        CFRunLoopStop(CFRunLoopGetCurrent())
      }
    })
    Leap.animateImage(command, animationDelay: startTime + (Double(i) / 2.0))
    CATransaction.commit()
  }

  CFRunLoopRun()
}

let command = Command(Process.arguments)

if command.needsHelp {
  printUsage(0)
} else if command.isNotValid {
  printCommandErrors(command)
  printUsage(1)
} else {
  if command.verboseOutput {
    printVerboseOutput()
  }
  leapThoseUnicorns()
}
