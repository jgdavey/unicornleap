import Cocoa

class LeapImage {
  var image: CGImage!
  var animationKeyPath = "position"

  init?(filename: String) {
    guard let source = CGDataProvider(filename: filename),
      let image = CGImage(pngDataProviderSource: source, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
      else { return nil }

    self.image = image
  }

  func addAnimation(_ seconds: Double, path: CGMutablePath, layer: CALayer, animationDelay: Double) {
    let animation = CAKeyframeAnimation()
    animation.keyPath = animationKeyPath
    animation.path = path
    animation.duration = seconds
    animation.calculationMode = CAAnimationCalculationMode.linear
    animation.beginTime = animationDelay

    layer.add(animation, forKey: animationKeyPath)
  }
}
