import Cocoa

class UnicornImage: LeapImage {
  var size: NSSize!
  var eccentricity: Float!
  let path = CGPathCreateMutable()
  let layer = CALayer()

  init?(filename: String, eccentricity: Float) {
    super.init(filename: filename)

    guard let size = NSImage(contentsOfFile: filename)?.size else { return nil }
    self.size = size
    self.eccentricity = eccentricity

    configurePath()
    configureLayer()
  }

  func addAnimation(seconds: Double, animationDelay: Double) {
    super.addAnimation(seconds, path: path, layer: layer, animationDelay: animationDelay)
  }

  private func configurePath() {
    let screen = NSScreen.mainScreen()!.frame
    let origin = CGPoint(x: -size.width, y: -size.height)
    let destination = CGPoint(x: screen.size.width + size.width, y: origin.y)
    let midpoint = (destination.x + origin.x) / 2.0
    let peak = size.height + screen.size.height * CGFloat(eccentricity) / 3.0

    CGPathMoveToPoint(path, nil, origin.x, origin.y)
    CGPathAddCurveToPoint(path, nil, midpoint, peak, midpoint, peak, destination.x, destination.y)
  }

  private func configureLayer() {
    layer.contents = image
    layer.bounds = CGRect(x: 0, y: 0, width: size.width, height: size.height)
    layer.position = CGPoint(x: -size.width, y: -size.height)
  }
}
