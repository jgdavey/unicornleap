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
      let unicornLayer = UnicornLayer(image: unicornImage.image, size: unicornImage.size)
      let emitter = Emitter.forImageInFrame(sparkleImage.image, imageSize: unicornImage.size, seconds: command.seconds!)

      floatingWindow.view.layer?.addSublayer(unicornLayer.layer)
      floatingWindow.view.layer?.addSublayer(emitter)

      let unicornAnimation = LeapAnimation(path: unicornImage.path, key: "position", seconds: Double(command.seconds!))
      unicornLayer.layer.addAnimation(unicornAnimation.animation, forKey: "position")

      let sparkleAnimation = LeapAnimation(path: unicornImage.path, key: "emitterPosition", seconds: Double(command.seconds!))
      emitter.addAnimation(sparkleAnimation.animation, forKey: "emitterPosition")

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
