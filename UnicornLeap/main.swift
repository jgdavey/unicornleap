import Cocoa

func printUsage(exitCode: Int32) {
  print(
    "Usage: unicornleap [options]\n",
    "  -h  --help             Display usage information.\n",
    "  -s  --seconds n        Animate for n seconds. (default: 2.0)\n",
    "  -n  --number i         Display i unicorns. (default: 1)\n",
    "  -e  --eccentricity x   Leap the unicorns with a higher peak. (default: 1.0)\n",
    "  -u  --unicorn file     Filename for unicorn image.\n",
    "  -k  --sparkle file     Filename for sparkle image.\n",
    "  -v  --verbose          Print verbose messages."
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

func leapManyUnicorns(n: Int, setupFunc: () -> () = {}) {
  let startTime = CACurrentMediaTime()

  for i in (0..<n) {
    CATransaction.begin()
    CATransaction.setCompletionBlock({
      if (i + 1 == n) {
        CFRunLoopStop(CFRunLoopGetCurrent())
      }
    })
    setupFunc()
    Leap.animateImage(command, animationDelay: startTime + Double(i) / 4.0)
    CATransaction.commit()
  }

  CFRunLoopRun()
}

func leapThoseUnicorns() {
  leapManyUnicorns(command.number!)
}

func herdThoseUnicorns() {
  let setupFunc = { command.eccentricity = Float(arc4random_uniform(30)) / 10.0 }
  leapManyUnicorns(30, setupFunc: setupFunc)
}

let command = Command(Process.arguments)

if command.needsHelp {
  printUsage(0)
} else if command.isNotValid {
  printCommandErrors(command)
  printUsage(1)
} else if command.herd {
  herdThoseUnicorns()
} else {
  if command.verboseOutput {
    printVerboseOutput()
  }
  leapThoseUnicorns()
}
