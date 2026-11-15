import Cocoa

struct StandardError: TextOutputStream {
  mutating func write(_ string: String) {
    FileHandle.standardError.write(Data(string.utf8))
  }
}
var standardError = StandardError()

// Usage goes to stdout when asked for (-h), and to stderr after an error.
func printUsage(_ exitCode: Int32) {
  var usage = ""
  print(
    "Usage: unicornleap [options]\n",
    "  -h  --help             Display usage information.\n",
    "  -s  --seconds n        Animate for n seconds. (default: 2.0)\n",
    "  -n  --number i         Display i unicorns. (default: 1)\n",
    "  -H  --herd             Enables herd-mode.\n",
    "  -e  --eccentricity x   Leap the unicorns with a higher peak. (default: 1.0)\n",
    "  -u  --unicorn file     Filename for unicorn image.\n",
    "  -k  --sparkle file     Filename for sparkle image.\n",
    "  -v  --verbose          Print verbose messages.\n",
    "  -V  --version          Print the version and exit.",
    to: &usage
  )

  if exitCode == 0 {
    print(usage, terminator: "")
  } else {
    print(usage, terminator: "", to: &standardError)
  }
  exit(exitCode)
}

func printCommandErrors(_ command: Command) {
  print("\(command.errors.joined(separator: "\n"))\n", to: &standardError)
}

func printImageError(_ filename: String) -> Never {
  print("unicornleap - valid PNG not found: \(filename)", to: &standardError)
  exit(1)
}

// Loads and decodes both images, or exits if either isn't a valid PNG, before
// anything appears on screen.
func loadImages() -> LeapImages {
  guard let unicorn = PNGImage.load(path: command.unicornFile!, defaultPath: Command.defaultUnicornFile, embeddedSection: "__unicorn_png")
    else { printImageError(command.unicornFile!) }
  guard let sparkle = PNGImage.load(path: command.sparkleFile!, defaultPath: Command.defaultSparkleFile, embeddedSection: "__sparkle_png")
    else { printImageError(command.sparkleFile!) }
  return LeapImages(unicorn: unicorn, sparkle: sparkle)
}

func printVerboseOutput() {
  print(command.verboseLines.joined(separator: "\n"))
}

// Connects to the window server (needed before creating windows) and returns
// the screen to leap across, or exits if there isn't one, e.g. when run from a
// session with no access to the display.
func mainScreenFrame() -> NSRect {
  _ = NSApplication.shared
  guard let screen = NSScreen.main else {
    print("unicornleap - no screen available to leap across", to: &standardError)
    exit(1)
  }
  return screen.frame
}

func leapManyUnicorns(_ n: Int, setupFunc: () -> () = {}) {
  let images = loadImages()
  let screenFrame = mainScreenFrame()

  // One window for every unicorn: each leap adds its own layers to it.
  let floatingWindow = FloatingWindow(rect: screenFrame)
  floatingWindow.view.wantsLayer = true
  // Borderless windows can't become key, and this process is never the
  // active app, so order the window front without activating.
  floatingWindow.window.orderFrontRegardless()
  guard let layer = floatingWindow.view.layer else { return }

  let startTime = CACurrentMediaTime()
  let offsetFactor = Double(command.seconds! / 8.0)

  for i in (0..<n) {
    CATransaction.begin()
    CATransaction.setCompletionBlock({
      if (i + 1 == n) {
        CFRunLoopStop(CFRunLoopGetCurrent())
      }
    })
    setupFunc()
    Leap.animateImage(command, in: layer, screenFrame: screenFrame, images: images, animationDelay: startTime + Double(i) * offsetFactor)
    CATransaction.commit()
  }

  CFRunLoopRun()
}

func leapThoseUnicorns() {
  leapManyUnicorns(command.leapCount!)
}

func herdThoseUnicorns() {
  let setupFunc = { command.eccentricity = Command.randomHerdEccentricity() }
  leapManyUnicorns(command.leapCount!, setupFunc: setupFunc)
}

let command = Command(CommandLine.arguments)

if command.needsHelp {
  printUsage(0)
} else if command.wantsVersion {
  print("unicornleap \(version)")
} else if command.isNotValid {
  printCommandErrors(command)
  printUsage(1)
} else {
  if command.verboseOutput {
    printVerboseOutput()
  }
  if command.herd {
    herdThoseUnicorns()
  } else {
    leapThoseUnicorns()
  }
}
