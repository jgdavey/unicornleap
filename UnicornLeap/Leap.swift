import Cocoa

// The decoded unicorn and sparkle images, loaded once and shared by every leap.
struct LeapImages {
  let unicorn: PNGImage
  let sparkle: PNGImage
}

// One unicorn and its sparkle trail.
struct Leap {
  let seconds: Float
  let unicornImage: UnicornImage
  let sparkleImage: SparkleImage

  init(seconds: Float, eccentricity: Float, screenFrame: NSRect, images: LeapImages) {
    self.seconds = seconds
    unicornImage = UnicornImage(image: images.unicorn, eccentricity: eccentricity, screenFrame: screenFrame)
    sparkleImage = SparkleImage(image: images.sparkle)
    sparkleImage.configureEmitter(unicornImage.size, seconds: seconds)
  }

  func animate(in layer: CALayer, animationDelay: Double) {
    layer.addSublayer(unicornImage.layer)
    layer.addSublayer(sparkleImage.emitter)

    unicornImage.addAnimation(Double(seconds), animationDelay: animationDelay)
    sparkleImage.addAnimation(Double(seconds), path: unicornImage.path, animationDelay: animationDelay)
  }

  // Call once the unicorn has landed: stops new sparkles, lets the ones already
  // emitted fade out, then removes the leap's layers and calls `completion`.
  // Without this, a landed leap's emitter keeps sparkling off screen.
  func land(then completion: @escaping () -> Void) {
    sparkleImage.stopEmitting()
    DispatchQueue.main.asyncAfter(deadline: .now() + sparkleImage.fadeOutSeconds) {
      self.remove()
      completion()
    }
  }

  func remove() {
    unicornImage.layer.removeFromSuperlayer()
    sparkleImage.emitter.removeFromSuperlayer()
  }
}
