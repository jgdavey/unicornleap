import Cocoa

class LeapImage {
  var image: CGImage!
  var animationKeyPath = "position"

  init?(filename: String) {
    guard let source = CGDataProviderCreateWithFilename(filename),
      image = CGImageCreateWithPNGDataProvider(source, nil, true, .RenderingIntentDefault)
      else { return nil }

    self.image = image
  }

  func addAnimation(seconds: Double, path: CGMutablePath, layer: CALayer, animationDelay: Double) {
    let animation = CAKeyframeAnimation()
    animation.keyPath = animationKeyPath
    animation.path = path
    animation.duration = seconds
    animation.calculationMode = kCAAnimationLinear
    animation.beginTime = animationDelay

    layer.addAnimation(animation, forKey: animationKeyPath)
  }
}
