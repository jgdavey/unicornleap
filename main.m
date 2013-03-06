#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

int main (int argc, const char * argv[]) {
    [NSApplication sharedApplication];

    CGMutablePathRef path;

    // Set up a fullscreen, transparent window/view
    NSWindow *window = [[NSWindow alloc] initWithContentRect: NSScreen.mainScreen.frame
                                                   styleMask: NSBorderlessWindowMask
                                                     backing: NSBackingStoreBuffered
                                                       defer: NO];
    [window setBackgroundColor:[NSColor colorWithCalibratedHue:0 saturation:0 brightness:0 alpha:0.0]];
    [window setOpaque: NO];
    [window setLevel: NSFloatingWindowLevel];

    NSView *view = [[NSView alloc] initWithFrame:NSScreen.mainScreen.frame];
    [window setContentView: view];

    // Choose image to display
    NSString *imagePath = [NSString stringWithFormat:@"%@/%@", NSHomeDirectory(), @".unicorn.png"];

    // Get image dimensions
    NSImage *image = [[NSImage alloc] initWithContentsOfFile: imagePath];
    CGSize imageSize = image.size;
    [image dealloc];


    // Load image as CGImage
    CGDataProviderRef source = CGDataProviderCreateWithFilename([imagePath UTF8String]);
    CGImageRef cgimage = CGImageCreateWithPNGDataProvider(source, NULL, true, 0);

    // Create a path to animate a layer on. We will also draw the path.
    path = CGPathCreateMutable();
    CGPoint origin = CGPointMake(-imageSize.width, -imageSize.height);
    CGPoint destination = CGPointMake(view.frame.size.width + imageSize.width, origin.y);
    CGFloat midpoint = (destination.x + origin.x) / 2.0;
    CGFloat peak = imageSize.height;
    CGPathMoveToPoint(path, NULL, origin.x, origin.y);

    CGPathAddCurveToPoint(path, NULL, midpoint, peak,
                            midpoint, peak,
                            destination.x, destination.y);

    // Create layer for image; This is the layer that animates
    CALayer *layer = [CALayer layer];

    [layer setContents: (id)(cgimage)];
    [layer setBounds:CGRectMake(0.0, 0.0, imageSize.width, imageSize.height)];
    [layer setPosition:CGPointMake(-imageSize.width, -imageSize.height)];

    [view setWantsLayer: YES];

    [view.layer addSublayer: layer];

    // Create the path animation, and add it oto the layer
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    [animation setPath: path];
    [animation setDuration: 2.0];
    [animation setCalculationMode: kCAAnimationLinear];
    [animation setRotationMode: nil];

    [layer addAnimation:animation forKey:@"position"];

    [window makeKeyAndOrderFront: nil];

    // Wait for animation to finish
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow: animation.duration]];

    return 0;
}
