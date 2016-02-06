import Cocoa

class LeapImage {
  let filename: String
  var image: CGImage!

  var imagePath: String {
    return "\(NSHomeDirectory())/.unicornleap/\(filename)"
  }

  init?(filename: String) {
    self.filename = filename
    guard let source = CGDataProviderCreateWithFilename(imagePath),
      image = CGImageCreateWithPNGDataProvider(source, nil, true, .RenderingIntentDefault)
      else { return nil }

    self.image = image
  }
}

class UnicornImage: LeapImage {
  var size: NSSize!
  let path = CGPathCreateMutable()
  let layer = CALayer()

  override init?(filename: String) {
    super.init(filename: filename)

    guard let size = NSImage(contentsOfFile: imagePath)?.size else { return nil }
    self.size = size

    configurePath()
    configureLayer()
  }

  private func configurePath() {
    let screen = NSScreen.mainScreen()!.frame
    let origin = CGPoint(x: -size.width, y: -size.height)
    let destination = CGPoint(x: screen.size.width + size.width, y: origin.y)
    let midpoint = (destination.x + origin.x) / 2.0
    let peak = size.height + 50.0

    CGPathMoveToPoint(path, nil, origin.x, origin.y)
    CGPathAddCurveToPoint(path, nil, midpoint, peak, midpoint, peak, destination.x, destination.y)
  }

  private func configureLayer() {
    layer.contents = image
    layer.bounds = CGRect(x: 0, y: 0, width: size.width, height: size.height)
    layer.position = CGPoint(x: -size.width, y: -size.height)
  }
}

class SparkleImage: LeapImage {}
