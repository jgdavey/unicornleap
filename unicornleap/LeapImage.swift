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

  func addAnimation(seconds: Double) {
    super.addAnimation(seconds, path: path, layer: layer)
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

class SparkleImage: LeapImage {
  let emitter = CAEmitterLayer()

  override init?(filename: String) {
    super.init(filename: filename)
    animationKeyPath = "emitterPosition"
  }

  func addAnimation(seconds: Double, path: CGMutablePath) {
    super.addAnimation(seconds, path: path, layer: emitter)
  }

  func configureEmitter(imageSize: CGSize, seconds: Float) {
    let base = 0.2

    emitter.emitterPosition = CGPoint(x: -imageSize.width, y: -imageSize.height)
    emitter.emitterSize = CGSize(width: imageSize.width / 1.5, height: imageSize.height / 1.5)

    let sparkle = CAEmitterCell()
    sparkle.contents = image
    sparkle.birthRate = 20.0 / seconds + 15.0
    sparkle.lifetime = seconds * 0.5 + Float(base)
    sparkle.lifetimeRange = 1.5
    sparkle.name = "sparkle"
    sparkle.color = CGColorCreateGenericRGB(1.0, 1.0, 1.0, 1.0)
    sparkle.greenSpeed = -0.7
    sparkle.minificationFilter = kCAFilterNearest
    sparkle.alphaSpeed = -1.0
    sparkle.scale = 0.8
    sparkle.scaleRange = 0.5
    sparkle.scaleSpeed = CGFloat(sparkle.alphaSpeed - Float(base))
    sparkle.velocity = -20.0
    sparkle.velocityRange = 20.0
    sparkle.yAcceleration = -100.0
    sparkle.xAcceleration = -50.0
    sparkle.spin = -2.0
    sparkle.spinRange = 4.0

    emitter.renderMode = kCAEmitterLayerAdditive
    emitter.emitterShape = kCAEmitterLayerCuboid
    emitter.emitterCells = [sparkle]
  }
}
