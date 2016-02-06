import Cocoa

class LeapImage {
  let filename: String
  var image: CGImage!
  var animationKeyPath = "position"

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

  func addAnimation(seconds: Double, path: CGMutablePath, layer: CALayer) {
    let animation = CAKeyframeAnimation()
    animation.keyPath = animationKeyPath
    animation.path = path
    animation.duration = seconds
    animation.calculationMode = kCAAnimationLinear

    layer.addAnimation(animation, forKey: animationKeyPath)
  }
}
