import Cocoa

class LeapImage {
  var image: CGImage!

  init?(path: String) {
    guard let source = CGDataProviderCreateWithFilename(path),
      image = CGImageCreateWithPNGDataProvider(source, nil, true, .RenderingIntentDefault)
      else { return nil }

    self.image = image
  }
}

class UnicornImage: LeapImage {
  var size: NSSize!

  override init?(path: String) {
    super.init(path: path)

    guard let size = NSImage(contentsOfFile: path)?.size else { return nil }
    self.size = size
  }
}

class SparkleImage: LeapImage {}
