import Cocoa

class UnicornLayer {
  let layer = CALayer()

  init(image: CGImageRef, size: CGSize) {
    layer.contents = image
    layer.bounds = CGRect(x: 0, y: 0, width: size.width, height: size.height)
    layer.position = CGPoint(x: -size.width, y: -size.height)
  }
}
