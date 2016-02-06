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
    let unicornFilename = "unicorn.png"
    let sparkleFilename = "sparkle.png"

    // I don't know what this does, but you need it
    NSApplication.sharedApplication()

    let screenFrame = NSScreen.mainScreen()!.frame
    let window = NSWindow(contentRect: screenFrame, styleMask: NSBorderlessWindowMask, backing: NSBackingStoreType.Buffered, `defer`: false)
    window.backgroundColor = NSColor(calibratedHue: 0, saturation: 0, brightness: 0, alpha: 0)
    window.opaque = false
    window.ignoresMouseEvents = true
    // this sucks - can we get this value another way??
    window.level = Int(CGWindowLevelForKey(CGWindowLevelKey.FloatingWindowLevelKey))

    let view = NSView(frame: screenFrame)
    window.contentView = view

    let folder: NSString = (NSHomeDirectory() as NSString).stringByAppendingPathComponent(".unicornleap")
    let imagePath = folder.stringByAppendingPathComponent(unicornFilename)
    let sparklePath = folder.stringByAppendingPathComponent(sparkleFilename)

    let image = NSImage(contentsOfFile: imagePath)

    if !image!.valid {
      invalidImage(imagePath)
      // this should probably throw up to main?
      return
    }

    let imageSize = image?.size

    let source = CGDataProviderCreateWithFilename(imagePath)
    let cgimage = CGImageCreateWithPNGDataProvider(source, nil, true, CGColorRenderingIntent.RenderingIntentDefault)

    let sparkleSource = CGDataProviderCreateWithFilename(sparklePath)

    // could this error checking be rolled into the other error checking?? seems redundant
    if sparkleSource == nil {
      invalidImage(sparklePath)
      // this should probably throw up to main?
      return
    }

    let sparkleImage = CGImageCreateWithPNGDataProvider(sparkleSource, nil, true, CGColorRenderingIntent.RenderingIntentDefault)

    let path = pathInFrameForSize(screenFrame, size: imageSize!)

    window.makeKeyAndOrderFront(nil)

    let waitFor = Double(command.seconds!/2.5)

    let runLoop = NSRunLoop.currentRunLoop()
    view.wantsLayer = true

    for _ in (1...command.number!) {
      let layer = layerForImageWithSize(cgimage!, size: imageSize!)
      let emitter = Emitter.forImageInFrame(sparkleImage!, imageSize: imageSize!, seconds: command.seconds!)

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
