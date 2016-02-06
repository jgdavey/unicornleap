import Cocoa

class Leap {
  let command: Command

  class func animateImage(command: Command) {
    Leap(command).animateImage()
  }

  init(_ command: Command) {
    self.command = command
  }

  func animateImage() {
    // I don't know what this does, but you need it
    NSApplication.sharedApplication()

    guard let unicornImage = UnicornImage(filename: "unicorn.png") else { invalidImage("unicorn.png"); return }
    guard let sparkleImage = SparkleImage(filename: "sparkle.png") else { invalidImage("sparkle.png"); return }

    let floatingWindow = FloatingWindow(rect: NSScreen.mainScreen()!.frame)

    floatingWindow.window.makeKeyAndOrderFront(nil)

    let waitFor = Double(command.seconds!/2.5)

    let runLoop = NSRunLoop.currentRunLoop()
    floatingWindow.view.wantsLayer = true

    for _ in (1...command.number!) {
      let emitter = Emitter.forImageInFrame(sparkleImage.image, imageSize: unicornImage.size, seconds: command.seconds!)

      floatingWindow.view.layer?.addSublayer(unicornImage.layer)
      floatingWindow.view.layer?.addSublayer(emitter)

      unicornImage.addAnimation(Double(command.seconds!))
      sparkleImage.addAnimation(Double(command.seconds!), path: unicornImage.path, layer: emitter)

      runLoop.runUntilDate(NSDate(timeIntervalSinceNow: Double(waitFor)))
    }

    runLoop.runUntilDate(NSDate(timeIntervalSinceNow: (Double(command.seconds!) - waitFor + 0.2)))
  }

  private func invalidImage(path: String) {
    // this should probably throw up to main?
    print("invalid Image")
    //  fprintf (stream, "ERROR: You must have a valid PNG image at %s\n", path);
    exit(127)
  }
}
