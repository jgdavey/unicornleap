import Cocoa

class Leap {
  let command: Command

  class func animateImage(_ command: Command, animationDelay: Double) {
    Leap(command).animateImage(animationDelay)
  }

  init(_ command: Command) {
    self.command = command
  }

  func animateImage(_ animationDelay: Double) {
    // Connects to the window server; needed before creating windows.
    _ = NSApplication.shared

    let floatingWindow = FloatingWindow(rect: NSScreen.main!.frame)

    // Borderless windows can't become key, and this process is never the
    // active app, so order the window front without activating.
    floatingWindow.window.orderFrontRegardless()

    floatingWindow.view.wantsLayer = true

    let unicornData = LeapImage.loadData(path: command.unicornFile!, defaultPath: Command.defaultUnicornFile, embeddedSection: "__unicorn_png")
    let sparkleData = LeapImage.loadData(path: command.sparkleFile!, defaultPath: Command.defaultSparkleFile, embeddedSection: "__sparkle_png")

    guard let unicornImage = unicornData.flatMap({ UnicornImage(data: $0, eccentricity: command.eccentricity!) }) else { printImageError(command.unicornFile!); return }
    guard let sparkleImage = sparkleData.flatMap({ SparkleImage(data: $0) }) else { printImageError(command.sparkleFile!); return }

    sparkleImage.configureEmitter(unicornImage.size, seconds: command.seconds!)

    floatingWindow.view.layer?.addSublayer(unicornImage.layer)
    floatingWindow.view.layer?.addSublayer(sparkleImage.emitter)

    unicornImage.addAnimation(Double(command.seconds!), animationDelay: animationDelay)
    sparkleImage.addAnimation(Double(command.seconds!), path: unicornImage.path, animationDelay: animationDelay)
  }
}
