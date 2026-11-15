import Cocoa
import MachO

// A decoded PNG, shared by every unicorn in a run.
struct PNGImage {
  let cgImage: CGImage
  // Size in points, which honors the PNG's DPI (unlike cgImage's pixel size).
  let size: NSSize

  init?(data: Data) {
    guard let source = CGDataProvider(data: data as CFData),
      let image = CGImage(pngDataProviderSource: source, decode: nil, shouldInterpolate: true, intent: .defaultIntent),
      let size = NSImage(data: data)?.size
      else { return nil }

    cgImage = image
    self.size = size
  }

  // Reads and decodes the PNG at `path`. If `path` is the default image
  // location and no file exists there, falls back to the copy embedded in the
  // binary at link time (`-sectcreate __TEXT <section> <png>`; see the Makefile).
  static func load(path: String, defaultPath: String, embeddedSection: String) -> PNGImage? {
    return loadData(path: path, defaultPath: defaultPath, embeddedSection: embeddedSection)
      .flatMap { PNGImage(data: $0) }
  }

  static func loadData(path: String, defaultPath: String, embeddedSection: String) -> Data? {
    if let data = FileManager.default.contents(atPath: path) { return data }
    guard path == defaultPath else { return nil }
    return embeddedData(section: embeddedSection)
  }

  static func embeddedData(section: String) -> Data? {
    let header = UnsafeRawPointer(#dsohandle).assumingMemoryBound(to: mach_header_64.self)
    var size: UInt = 0
    guard let bytes = getsectiondata(header, "__TEXT", section, &size), size > 0 else { return nil }
    return Data(bytes: bytes, count: Int(size))
  }
}

class LeapImage {
  let image: PNGImage
  var animationKeyPath = "position"

  init(image: PNGImage) {
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
