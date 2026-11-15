import Cocoa

// The decoded unicorn and sparkle images, loaded once and shared by every leap.
struct LeapImages {
  let unicorn: PNGImage
  let sparkle: PNGImage
}

class Leap {
  let command: Command
  let screenFrame: NSRect
  let images: LeapImages

  class func animateImage(_ command: Command, in layer: CALayer, screenFrame: NSRect, images: LeapImages, animationDelay: Double) {
    Leap(command, screenFrame: screenFrame, images: images).animateImage(in: layer, animationDelay: animationDelay)
  }

  init(_ command: Command, screenFrame: NSRect, images: LeapImages) {
    self.command = command
    self.screenFrame = screenFrame
    self.images = images
  }

  func animateImage(in layer: CALayer, animationDelay: Double) {
    let unicornImage = UnicornImage(image: images.unicorn, eccentricity: command.eccentricity!, screenFrame: screenFrame)
    let sparkleImage = SparkleImage(image: images.sparkle)

    sparkleImage.configureEmitter(unicornImage.size, seconds: command.seconds!)

    layer.addSublayer(unicornImage.layer)
    layer.addSublayer(sparkleImage.emitter)

    unicornImage.addAnimation(Double(command.seconds!), animationDelay: animationDelay)
    sparkleImage.addAnimation(Double(command.seconds!), path: unicornImage.path, animationDelay: animationDelay)
  }
}
