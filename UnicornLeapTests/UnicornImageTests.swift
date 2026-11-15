import Cocoa
import Testing
@testable import unicornleap

/// A blank PNG of `pixels` that claims to be `points` in size (i.e. a DPI other
/// than 72 when they differ).
private func png(pixels: NSSize, points: NSSize? = nil) throws -> PNGImage {
  let rep = try #require(NSBitmapImageRep(
    bitmapDataPlanes: nil, pixelsWide: Int(pixels.width), pixelsHigh: Int(pixels.height),
    bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
    colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0))
  rep.size = points ?? pixels
  let data = try #require(rep.representation(using: .png, properties: [:]))
  return try #require(PNGImage(data: data))
}

/// The points of a path's elements, in order (curves contribute their control
/// points and end point).
private func points(of path: CGPath) -> [(CGPathElementType, [CGPoint])] {
  var result = [(CGPathElementType, [CGPoint])]()
  path.applyWithBlock { pointer in
    let element = pointer.pointee
    let count: Int
    switch element.type {
    case .moveToPoint, .addLineToPoint: count = 1
    case .addQuadCurveToPoint: count = 2
    case .addCurveToPoint: count = 3
    default: count = 0
    }
    result.append((element.type, (0..<count).map { element.points[$0] }))
  }
  return result
}

@Suite struct UnicornImageTests {
  let screen = NSRect(x: 0, y: 0, width: 1440, height: 900)
  let unicornSize = NSSize(width: 200, height: 100)

  // MARK: PNGImage

  @Test func pngSizeIsInPoints() throws {
    let image = try png(pixels: NSSize(width: 400, height: 200), points: NSSize(width: 200, height: 100))
    #expect(image.size == NSSize(width: 200, height: 100))
    #expect(image.cgImage.width == 400)
  }

  @Test func pngRejectsDataThatIsNotAPNG() {
    #expect(PNGImage(data: Data("not a png".utf8)) == nil)
  }

  // MARK: path

  @Test func pathIsOneCurveBetweenTheBottomCornersOffScreen() throws {
    let unicorn = UnicornImage(image: try png(pixels: unicornSize), eccentricity: 1, screenFrame: screen)
    let elements = points(of: unicorn.path)

    try #require(elements.count == 2)
    #expect(elements[0].0 == .moveToPoint)
    #expect(elements[0].1 == [CGPoint(x: -200, y: -100)])
    #expect(elements[1].0 == .addCurveToPoint)
    // Both control points sit at the peak above the middle of the screen:
    // the unicorn's height plus a third of the screen per unit of eccentricity.
    let peak = CGPoint(x: 720, y: 100 + 900 / 3)
    #expect(elements[1].1 == [peak, peak, CGPoint(x: 1440 + 200, y: -100)])
  }

  @Test(arguments: [0, 0.5, 1, 2, 3] as [Float])
  func eccentricityScalesThePeak(eccentricity: Float) throws {
    let unicorn = UnicornImage(image: try png(pixels: unicornSize), eccentricity: eccentricity, screenFrame: screen)
    let control = try #require(points(of: unicorn.path).last?.1.first)
    #expect(control.x == 720)
    #expect(abs(control.y - (100 + 900 * CGFloat(eccentricity) / 3)) < 0.001)
  }

  // The path is in the window's own coordinates, so a screen that isn't at the
  // origin (e.g. a second display) gets the same path as one that is.
  @Test func pathIgnoresTheScreenOrigin() throws {
    let image = try png(pixels: unicornSize)
    let atOrigin = UnicornImage(image: image, eccentricity: 1, screenFrame: screen)
    let offset = UnicornImage(image: image, eccentricity: 1, screenFrame: screen.offsetBy(dx: -1440, dy: 300))
    #expect(atOrigin.path.boundingBoxOfPath == offset.path.boundingBoxOfPath)
  }

  @Test func pathScalesWithTheScreen() throws {
    let image = try png(pixels: unicornSize)
    let small = UnicornImage(image: image, eccentricity: 1, screenFrame: NSRect(x: 0, y: 0, width: 800, height: 600))
    // A tight bounding box isn't exact, so compare within rounding error.
    let box = small.path.boundingBoxOfPath
    #expect(abs(box.minX - -200) < 0.01)
    #expect(abs(box.maxX - (800 + 200)) < 0.01)
  }

  // The unicorn starts and ends fully off screen, and with the default
  // eccentricity its top stays on screen at the height of the leap.
  @Test func defaultLeapStaysOnScreenAtItsPeak() throws {
    let unicorn = UnicornImage(image: try png(pixels: unicornSize), eccentricity: 1, screenFrame: screen)
    let box = unicorn.path.boundingBoxOfPath
    // The layer is centered on the path.
    #expect(box.minY + 100 / 2 <= 0)
    #expect(box.maxY + 100 / 2 < screen.height)
    #expect(box.maxY - 100 / 2 > 0)
  }

  // MARK: layer

  @Test func layerMatchesTheImageAndStartsOffScreen() throws {
    let image = try png(pixels: NSSize(width: 400, height: 200), points: unicornSize)
    let unicorn = UnicornImage(image: image, eccentricity: 1, screenFrame: screen)
    #expect(unicorn.size == unicornSize)
    #expect(unicorn.layer.bounds == CGRect(origin: .zero, size: unicornSize))
    #expect(unicorn.layer.position == CGPoint(x: -200, y: -100))
    #expect(unicorn.layer.contents as! CGImage === image.cgImage)
  }
}
