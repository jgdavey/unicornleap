import Cocoa

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
