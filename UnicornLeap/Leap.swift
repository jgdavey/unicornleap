import Cocoa

// The decoded unicorn and sparkle images, loaded once and shared by every leap.
struct LeapImages {
  let unicorn: PNGImage
  let sparkle: PNGImage
}

// One unicorn and its sparkle trail.
struct Leap {
  let seconds: Float
  let eccentricity: Float
  let screenFrame: NSRect
  let images: LeapImages

  func animate(in layer: CALayer, animationDelay: Double) {
    let unicornImage = UnicornImage(image: images.unicorn, eccentricity: eccentricity, screenFrame: screenFrame)
    let sparkleImage = SparkleImage(image: images.sparkle)

    sparkleImage.configureEmitter(unicornImage.size, seconds: seconds)

    layer.addSublayer(unicornImage.layer)
    layer.addSublayer(sparkleImage.emitter)

    unicornImage.addAnimation(Double(seconds), animationDelay: animationDelay)
    sparkleImage.addAnimation(Double(seconds), path: unicornImage.path, animationDelay: animationDelay)
  }
}
