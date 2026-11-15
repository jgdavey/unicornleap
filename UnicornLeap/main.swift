import Cocoa

struct StandardError: TextOutputStream {
  mutating func write(_ string: String) {
    FileHandle.standardError.write(Data(string.utf8))
  }
}
var standardError = StandardError()

// Parses the arguments, or exits: help goes to stdout with status 0, and an
// error (with the usage line) goes to stderr with status 1.
func parseCommand() -> Command {
  do {
    return try Command.parse()
  } catch {
    let message = Command.fullMessage(for: error)
    if Command.exitCode(for: error) == .success {
      print(message)
      exit(0)
    }
    print(message, to: &standardError)
    exit(1)
  }
}

func printImageError(_ filename: String) -> Never {
  print("unicornleap - valid PNG not found: \(filename)", to: &standardError)
  exit(1)
}

// Loads and decodes both images, or exits if either isn't a valid PNG, before
// anything appears on screen.
func loadImages(_ command: Command) -> LeapImages {
  guard let unicorn = PNGImage.load(path: command.unicornFile, defaultPath: Command.defaultUnicornFile, embeddedSection: "__unicorn_png")
    else { printImageError(command.unicornFile) }
  guard let sparkle = PNGImage.load(path: command.sparkleFile, defaultPath: Command.defaultSparkleFile, embeddedSection: "__sparkle_png")
    else { printImageError(command.sparkleFile) }
  return LeapImages(unicorn: unicorn, sparkle: sparkle)
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

func leapManyUnicorns(_ command: Command) {
  let images = loadImages(command)
  let screenFrame = mainScreenFrame()

  // One window for every unicorn: each leap adds its own layers to it.
  let floatingWindow = FloatingWindow(rect: screenFrame)
  floatingWindow.view.wantsLayer = true
  // Borderless windows can't become key, and this process is never the
  // active app, so order the window front without activating.
  floatingWindow.window.orderFrontRegardless()
  guard let layer = floatingWindow.view.layer else { return }

  let startTime = CACurrentMediaTime()
  let offsetFactor = Double(command.seconds / 8.0)

  for i in (0..<command.leapCount) {
    CATransaction.begin()
    CATransaction.setCompletionBlock({
      if (i + 1 == command.leapCount) {
        CFRunLoopStop(CFRunLoopGetCurrent())
      }
    })
    let leap = Leap(seconds: command.seconds, eccentricity: command.eccentricityForNextLeap(),
                    screenFrame: screenFrame, images: images)
    leap.animate(in: layer, animationDelay: startTime + Double(i) * offsetFactor)
    CATransaction.commit()
  }

  CFRunLoopRun()
}

let command = parseCommand()

if command.version {
  print("unicornleap \(version)")
} else {
  if command.verbose {
    print(command.verboseLines.joined(separator: "\n"))
  }
  leapManyUnicorns(command)
}
