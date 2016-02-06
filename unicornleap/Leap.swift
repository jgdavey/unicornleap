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

    let path = pathInFrameForSize(NSScreen.mainScreen()!.frame, size: unicornImage.size)

    floatingWindow.window.makeKeyAndOrderFront(nil)

    let waitFor = Double(command.seconds!/2.5)

    let runLoop = NSRunLoop.currentRunLoop()
    floatingWindow.view.wantsLayer = true

    for _ in (1...command.number!) {
      let layer = layerForImageWithSize(unicornImage.image, size: unicornImage.size)
      let emitter = Emitter.forImageInFrame(sparkleImage.image, imageSize: unicornImage.size, seconds: command.seconds!)

      floatingWindow.view.layer?.addSublayer(layer)
      floatingWindow.view.layer?.addSublayer(emitter)

      animateLayerAlongPathForKey(layer, path: path, key: "position", seconds: Double(command.seconds!))
      animateLayerAlongPathForKey(emitter, path: path, key: "emitterPosition", seconds: Double(command.seconds!))

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

  private func pathInFrameForSize(screen: CGRect, size: CGSize) -> CGMutablePathRef {
    let path = CGPathCreateMutable()
    let origin = CGPoint(x: -size.width, y: -size.height)
    let destination = CGPoint(x: screen.size.width + size.width, y: origin.y)
    let midpoint = (destination.x + origin.x) / 2.0
    let peak = size.height + 50.0

    CGPathMoveToPoint(path, nil, origin.x, origin.y)
    CGPathAddCurveToPoint(path, nil, midpoint, peak, midpoint, peak, destination.x, destination.y)

    return path
  }

  private func layerForImageWithSize(image: CGImageRef, size: CGSize) -> CALayer {
    let layer = CALayer()
    layer.contents = image
    layer.bounds = CGRect(x: 0, y: 0, width: size.width, height: size.height)
    layer.position = CGPoint(x: -size.width, y: -size.height)
    return layer
  }

  private func animateLayerAlongPathForKey(layer: CALayer, path: CGMutablePathRef, key: String, seconds: Double) {
    let animation = CAKeyframeAnimation(keyPath: key)
    animation.path = path
    animation.duration = seconds
    animation.calculationMode = kCAAnimationLinear
    animation.rotationMode = nil
    layer.addAnimation(animation, forKey: key)
  }
}
