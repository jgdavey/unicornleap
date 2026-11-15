import Cocoa

class UnicornImage: LeapImage {
  var size: NSSize!
  var eccentricity: Float!
  let path = CGMutablePath()
  let layer = CALayer()

  init?(data: Data, eccentricity: Float, screenFrame: NSRect) {
    super.init(data: data)

    guard let size = NSImage(data: data)?.size else { return nil }
    self.size = size
    self.eccentricity = eccentricity

    configurePath(screenFrame)
    configureLayer()
  }

  func addAnimation(_ seconds: Double, animationDelay: Double) {
    super.addAnimation(seconds, path: path, layer: layer, animationDelay: animationDelay)
  }

  fileprivate func configurePath(_ screen: NSRect) {
    let origin = CGPoint(x: -size.width, y: -size.height)
    let destination = CGPoint(x: screen.size.width + size.width, y: origin.y)
    let midpoint = (destination.x + origin.x) / 2.0
    let peak = size.height + screen.size.height * CGFloat(eccentricity) / 3.0
    let curvePeak = CGPoint(x: midpoint, y: peak)

    path.move(to: origin)
    path.addCurve(to: destination, control1: curvePeak, control2: curvePeak)
  }

  fileprivate func configureLayer() {
    layer.contents = image
    layer.bounds = CGRect(x: 0, y: 0, width: size.width, height: size.height)
    layer.position = CGPoint(x: -size.width, y: -size.height)
  }
}
