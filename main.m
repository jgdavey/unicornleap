#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

int main (int argc, const char * argv[]) {
    [NSApplication sharedApplication];

    CGMutablePathRef path;

    NSWindow *window = [[NSWindow alloc] initWithContentRect: NSScreen.mainScreen.frame
                                                   styleMask: NSBorderlessWindowMask
                                                     backing: NSBackingStoreBuffered
                                                       defer: NO];
    [window setBackgroundColor:[NSColor colorWithCalibratedHue:0 saturation:0 brightness:0 alpha:0.0]];
    [window setOpaque: NO];
    [window setLevel: NSFloatingWindowLevel];

    NSString *imagePath = [NSString stringWithFormat:@"%@/%@", NSHomeDirectory(), @".unicorn.png"];

    NSImage *image = [[NSImage alloc] initWithContentsOfFile: imagePath];
    /* CGImageSourceRef source; */
    /* source = CGImageSourceCreateWithData((__bridge CFDataRef)[image TIFFRepresentation], NULL); */
    /* CGImageRef cgimage = CGImageSourceCreateImageAtIndex(source, 0, NULL); */

    NSView *view = [[NSView alloc] initWithFrame:NSScreen.mainScreen.frame];
    [window setContentView: view];


    CGDataProviderRef source = CGDataProviderCreateWithFilename([imagePath UTF8String]);

    CGImageRef cgimage = CGImageCreateWithPNGDataProvider(source, NULL, true, 0);

    {   // Create a path to animate a layer on. We will also draw the path.
        path = CGPathCreateMutable();
        CGPoint origin = CGPointMake(-image.size.width, -image.size.height);
        CGPoint destination = CGPointMake(view.frame.size.width + image.size.width, origin.y);
        CGFloat midpoint = (destination.x + origin.x) / 2.0;
        CGFloat peak = image.size.height;
        CGPathMoveToPoint(path, NULL, origin.x, origin.y);

        CGPathAddCurveToPoint(path, NULL, midpoint, peak,
                              midpoint, peak,
                              destination.x, destination.y);

    }

    // This is the layer that animates along the path.
    CALayer *layer = [CALayer layer];

    [layer setContents: (id)(cgimage)];
    [layer setBounds:CGRectMake(0.0, 0.0, image.size.width, image.size.height)];
    [layer setPosition:CGPointMake(-image.size.width, -image.size.height)];

    [view setWantsLayer: YES];

    [view.layer addSublayer: layer];

    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    [animation setPath: path];
    [animation setDuration: 2.0];
    [animation setCalculationMode: kCAAnimationLinear];
    [animation setRotationMode: nil];

    [layer addAnimation:animation forKey:@"position"];

    [window makeKeyAndOrderFront: nil];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow: animation.duration]];

    return 0;
}
