#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
#include <getopt.h>
#include <stdio.h>
#include <stdlib.h>

const char* program_name;
const char* short_options = "hs:v";
const struct option long_options[] = {
    { "help",    0, NULL, 'h' },
    { "seconds", 1, NULL, 'o' },
    { "verbose", 0, NULL, 'v' },
    { NULL,      0, NULL, 0   }   /* Required at end of array.  */
};

void print_usage (FILE* stream, int exit_code) {
    fprintf (stream, "Usage:  %s [options]\n", program_name);
    fprintf (stream,
             "  -h  --help           Display this usage information.\n"
             "  -s  --seconds n      Animate for n seconds.\n"
             "  -v  --verbose        Print verbose messages.\n");
    exit (exit_code);
}

void animateImage (double seconds) {
    // Objective C
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
    [animation setDuration: seconds];
    [animation setCalculationMode: kCAAnimationLinear];
    [animation setRotationMode: nil];

    [layer addAnimation:animation forKey:@"position"];

    [window makeKeyAndOrderFront: nil];

    // Wait for animation to finish
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow: animation.duration]];

    [imagePath release];
    [view release];
    [window release];
    return;
}

int main (int argc, char * argv[]) {
    program_name = argv[0];

    // Defaults
    char* s = NULL;
    int verbose = 0;
    double seconds = 2.0;

    // Parse options
    int next_option;

    do {
        next_option = getopt_long(argc, argv, short_options, long_options, NULL);
        switch(next_option)
        {
            case 's':
                s = optarg;
                break;

            case 'v':
                verbose = 1;
                break;

            case 'h': print_usage(stdout, 0);
            case '?': print_usage(stderr, 1);
            case -1:  break;
            default:  abort();
        }
    } while (next_option != -1);

    // Coerce string to double
    if (NULL != s) seconds = strtod(s, NULL);
    if (! seconds > 0.0) seconds = 2.0;

    if (verbose) {
        printf("Seconds: %f\n", seconds);
    }

    animateImage(seconds);
    return 0;
}
