import Cocoa

class LeapImage {
  let filename: String
  var image: CGImage!

  var path: String {
    return "\(NSHomeDirectory())/.unicornleap/\(filename)"
  }

  init?(filename: String) {
    self.filename = filename
    guard let source = CGDataProviderCreateWithFilename(path),
      image = CGImageCreateWithPNGDataProvider(source, nil, true, .RenderingIntentDefault)
      else { return nil }

    self.image = image
  }
}

class UnicornImage: LeapImage {
  var size: NSSize!

  override init?(filename: String) {
    super.init(filename: filename)

    guard let size = NSImage(contentsOfFile: path)?.size else { return nil }
    self.size = size
  }
}

class SparkleImage: LeapImage {}
