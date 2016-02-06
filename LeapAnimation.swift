import Cocoa

class LeapAnimation {
  let animation = CAKeyframeAnimation()

  init(path: CGMutablePathRef, key: String, seconds: Double) {
    animation.keyPath = key
    animation.path = path
    animation.duration = seconds
    animation.calculationMode = kCAAnimationLinear
  }
}
