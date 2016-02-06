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

    guard let unicornImage = UnicornImage(filename: "unicorn.png") else { printImageError("unicorn.png"); return }
    guard let sparkleImage = SparkleImage(filename: "sparkle.png") else { printImageError("sparkle.png"); return }

    let floatingWindow = FloatingWindow(rect: NSScreen.mainScreen()!.frame)

    floatingWindow.window.makeKeyAndOrderFront(nil)

    let waitFor = Double(command.seconds!/2.5)

    let runLoop = NSRunLoop.currentRunLoop()
    floatingWindow.view.wantsLayer = true

    for _ in (1...command.number!) {
      sparkleImage.configureEmitter(unicornImage.size, seconds: command.seconds!)

      floatingWindow.view.layer?.addSublayer(unicornImage.layer)
      floatingWindow.view.layer?.addSublayer(sparkleImage.emitter)

      unicornImage.addAnimation(Double(command.seconds!))
      sparkleImage.addAnimation(Double(command.seconds!), path: unicornImage.path)

      runLoop.runUntilDate(NSDate(timeIntervalSinceNow: Double(waitFor)))
    }

    runLoop.runUntilDate(NSDate(timeIntervalSinceNow: (Double(command.seconds!) - waitFor + 0.2)))
  }
}
