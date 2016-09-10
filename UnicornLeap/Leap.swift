import Cocoa

class Leap {
  let command: Command

  class func animateImage(command: Command, animationDelay: Double) {
    Leap(command).animateImage(animationDelay)
  }

  init(_ command: Command) {
    self.command = command
  }

  func animateImage(animationDelay: Double) {
    // I don't know what this does, but you need it
    NSApplication.sharedApplication()

    let floatingWindow = FloatingWindow(rect: NSScreen.mainScreen()!.frame)

    floatingWindow.window.makeKeyAndOrderFront(nil)


    floatingWindow.view.wantsLayer = true

    guard let unicornImage = UnicornImage(filename: command.unicornFile!, eccentricity: command.eccentricity!) else { printImageError(command.unicornFile!); return }
    guard let sparkleImage = SparkleImage(filename: command.sparkleFile!) else { printImageError(command.sparkleFile!); return }

    sparkleImage.configureEmitter(unicornImage.size, seconds: command.seconds!)

    floatingWindow.view.layer?.addSublayer(unicornImage.layer)
    floatingWindow.view.layer?.addSublayer(sparkleImage.emitter)

    unicornImage.addAnimation(Double(command.seconds!), animationDelay: animationDelay)
    sparkleImage.addAnimation(Double(command.seconds!), path: unicornImage.path, animationDelay: animationDelay)
  }
}
