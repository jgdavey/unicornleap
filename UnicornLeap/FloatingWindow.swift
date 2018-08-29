import Cocoa

class FloatingWindow {
  let window: NSWindow
  let view: NSView

  init(rect: NSRect) {
    window = NSWindow(contentRect: rect, styleMask: .borderless, backing: .buffered, defer: false)
    window.backgroundColor = NSColor.clear
    window.isOpaque = false
    window.ignoresMouseEvents = true
    window.level = NSWindow.Level(Int(CGWindowLevelForKey(.floatingWindow)))

    view = NSView(frame: rect)
    window.contentView = view
  }
}
