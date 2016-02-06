import Cocoa

class FloatingWindow {
  let window: NSWindow
  let view: NSView

  init(rect: NSRect) {
    window = NSWindow(contentRect: rect, styleMask: NSBorderlessWindowMask, backing: .Buffered, `defer`: false)
    window.backgroundColor = NSColor.clearColor()
    window.opaque = false
    window.ignoresMouseEvents = true
    window.level = Int(CGWindowLevelForKey(.FloatingWindowLevelKey))

    view = NSView(frame: rect)
    window.contentView = view
  }
}
