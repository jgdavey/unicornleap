import Cocoa
import MachO

class LeapImage {
  var image: CGImage!
  var animationKeyPath = "position"

  init?(data: Data) {
    guard let source = CGDataProvider(data: data as CFData),
      let image = CGImage(pngDataProviderSource: source, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
      else { return nil }

    self.image = image
  }

  // Reads PNG data from `path`. If `path` is the default image location and
  // no file exists there, falls back to the copy embedded in the binary at
  // link time (`-sectcreate __TEXT <section> <png>`; see the Makefile).
  class func loadData(path: String, defaultPath: String, embeddedSection: String) -> Data? {
    if let data = FileManager.default.contents(atPath: path) { return data }
    guard path == defaultPath else { return nil }
    return embeddedData(section: embeddedSection)
  }

  class func embeddedData(section: String) -> Data? {
    let header = UnsafeRawPointer(#dsohandle).assumingMemoryBound(to: mach_header_64.self)
    var size: UInt = 0
    guard let bytes = getsectiondata(header, "__TEXT", section, &size), size > 0 else { return nil }
    return Data(bytes: bytes, count: Int(size))
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
