import Cocoa

private func imageFromPath(path: String) -> CGImage? {
  guard let source = CGDataProviderCreateWithFilename(path) else { return nil }
  return CGImageCreateWithPNGDataProvider(source, nil, true, .RenderingIntentDefault)
}

class Leap {
  let command: Command

  var unicornCGImage: CGImage?
  var sparkleCGImage: CGImage?
  var unicornSize: NSSize?

  class func animateImage(command: Command) {
    Leap(command).animateImage()
  }

  init(_ command: Command) {
    self.command = command

    let folder: NSString = (NSHomeDirectory() as NSString).stringByAppendingPathComponent(".unicornleap")

    let unicornPath = folder.stringByAppendingPathComponent("unicorn.png")
    let sparklePath = folder.stringByAppendingPathComponent("sparkle.png")

    unicornCGImage = imageFromPath(unicornPath)
    sparkleCGImage = imageFromPath(sparklePath)

    unicornSize = NSImage(contentsOfFile: unicornPath)?.size
  }

  func animateImage() {
    // I don't know what this does, but you need it
    NSApplication.sharedApplication()

    guard let unicornImage = unicornCGImage else { invalidImage("unicorn.png"); return }
    guard let sparkleImage = sparkleCGImage else { invalidImage("sparkle.png"); return }

    guard let unicornSize = unicornSize else { return }

    let screenFrame = NSScreen.mainScreen()!.frame
    let window = NSWindow(contentRect: screenFrame, styleMask: NSBorderlessWindowMask, backing: NSBackingStoreType.Buffered, `defer`: false)
    window.backgroundColor = NSColor(calibratedHue: 0, saturation: 0, brightness: 0, alpha: 0)
    window.opaque = false
    window.ignoresMouseEvents = true
    window.level = Int(CGWindowLevelForKey(.FloatingWindowLevelKey))

    let view = NSView(frame: screenFrame)
    window.contentView = view

    let path = pathInFrameForSize(screenFrame, size: unicornSize)

    window.makeKeyAndOrderFront(nil)

    let waitFor = Double(command.seconds!/2.5)

    let runLoop = NSRunLoop.currentRunLoop()
    view.wantsLayer = true

    for _ in (1...command.number!) {
      let layer = layerForImageWithSize(unicornImage, size: unicornSize)
      let emitter = Emitter.forImageInFrame(sparkleImage, imageSize: unicornSize, seconds: command.seconds!)

      view.layer?.addSublayer(layer)
      view.layer?.addSublayer(emitter)

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
