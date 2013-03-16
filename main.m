#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
#include <getopt.h>
#include <stdio.h>
#include <stdlib.h>

const char* program_name;
double seconds;
const char* short_options = "hs:v";
const struct option long_options[] = {
    { "help",    0, NULL, 'h' },
    { "seconds", 1, NULL, 's' },
    { "verbose", 0, NULL, 'v' },
    { NULL,      0, NULL, 0   }   /* Required at end of array.  */
};

void invalid_image(FILE* stream, char * path) {
    fprintf (stream, "ERROR: You must have a valid PNG image at %s\n", path);
    exit(127);
}

void print_usage (FILE* stream, int exit_code) {
    fprintf (stream, "Usage:  %s [options]\n", program_name);
    fprintf (stream,
             "  -h  --help           Display this usage information.\n"
             "  -s  --seconds n      Animate for n seconds.\n"
             "  -v  --verbose        Print verbose messages.\n");
    exit (exit_code);
}

CAEmitterLayer * getEmitterForImageInFrame (CGImageRef sparkleImage, CGSize imageSize) {
    static float base = 0.2;

    CAEmitterLayer *emitter = [[CAEmitterLayer alloc] init];
    emitter.emitterPosition = CGPointMake(-imageSize.width, -imageSize.height);
    emitter.emitterSize = CGSizeMake(imageSize.width/1.5, imageSize.height/1.5);
    CAEmitterCell *sparkle = [CAEmitterCell emitterCell];

    sparkle.contents = (id)(sparkleImage);

    sparkle.birthRate = 20.0/seconds + 15.0;
    sparkle.lifetime = seconds * 0.5 + base;
    sparkle.lifetimeRange = 1.5;
    sparkle.name = @"sparkle";

    // Fade from white to purple
    sparkle.color = CGColorCreateGenericRGB(1.0, 1.0, 1.0, 1.0);
    sparkle.greenSpeed = -0.7;

    sparkle.minificationFilter = kCAFilterNearest;

    // Fade out
    sparkle.alphaSpeed = -1.0;

    // Shrink
    sparkle.scale = 0.8;
    sparkle.scaleRange = 0.5;
    sparkle.scaleSpeed = sparkle.alphaSpeed - base;

    // Fall away
    sparkle.velocity = -20.0;
    sparkle.velocityRange = 20.0;
    sparkle.yAcceleration = -100.0;
    sparkle.xAcceleration = -50.0;

    // Spin
    sparkle.spin = -2.0;
    sparkle.spinRange = 4.0;

    emitter.renderMode = kCAEmitterLayerAdditive;
    emitter.emitterShape = kCAEmitterLayerCuboid;
    emitter.emitterCells = [NSArray arrayWithObject:sparkle];
    return emitter;
}

CGMutablePathRef pathInFrameForSize (CGRect screen, CGSize size) {
    CGMutablePathRef path = CGPathCreateMutable();
    CGPoint origin = CGPointMake(-size.width, -size.height);
    CGPoint destination = CGPointMake(screen.size.width + size.width, origin.y);
    CGFloat midpoint = (destination.x + origin.x) / 2.0;
    CGFloat peak = size.height + 50.0;
    CGPathMoveToPoint(path, NULL, origin.x, origin.y);

    CGPathAddCurveToPoint(path, NULL, midpoint, peak,
                          midpoint, peak,
                          destination.x, destination.y);
    return path;
};

void animateLayerAlongPathForKey (CALayer *layer, CGMutablePathRef path, NSString *key) {
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:key];
    [animation setPath: path];
    [animation setDuration: seconds];
    [animation setCalculationMode: kCAAnimationLinear];
    [animation setRotationMode: nil];
    [layer addAnimation:animation forKey:key];
}

void animateImage () {
    // Objective C
    [NSApplication sharedApplication];

    CGMutablePathRef path;

    // Set up a fullscreen, transparent window/view
    CGRect screen = NSScreen.mainScreen.frame;

    NSWindow *window = [[NSWindow alloc] initWithContentRect: screen
                                                   styleMask: NSBorderlessWindowMask
                                                     backing: NSBackingStoreBuffered
                                                       defer: NO];
    [window setBackgroundColor:[NSColor colorWithCalibratedHue:0 saturation:0 brightness:0 alpha:0.0]];
    [window setOpaque: NO];
    [window setIgnoresMouseEvents:YES];
    [window setLevel: NSFloatingWindowLevel];

    NSView *view = [[NSView alloc] initWithFrame:screen];
    [window setContentView: view];

    // Gather image paths
    NSString *folder = [NSHomeDirectory() stringByAppendingPathComponent:@".unicornleap"];
    NSString *imagePath = [folder stringByAppendingPathComponent:@"unicorn.png"];
    NSString *sparklePath = [folder stringByAppendingPathComponent:@"sparkle.png"];

    // Get image dimensions
    NSImage *image = [[NSImage alloc] initWithContentsOfFile: imagePath];

    if(![image isValid]) {
        invalid_image(stderr, (char *)[imagePath UTF8String]);
        return;
    }

    CGSize imageSize = image.size;
    [image dealloc];

    // Load image as CGImage
    CGDataProviderRef source = CGDataProviderCreateWithFilename([imagePath UTF8String]);
    CGImageRef cgimage = CGImageCreateWithPNGDataProvider(source, NULL, true, 0);

    // Create a path to animate a layer on. We will also draw the path.
    path = pathInFrameForSize(screen, imageSize);

    // Create layer for image; This is the layer that animates
    CALayer *layer = [CALayer layer];

    [layer setContents: (id)(cgimage)];
    [layer setBounds:CGRectMake(0.0, 0.0, imageSize.width, imageSize.height)];
    [layer setPosition:CGPointMake(-imageSize.width, -imageSize.height)];

    [view setWantsLayer: YES];

    [view.layer addSublayer: layer];

    CGDataProviderRef sparkleSource = CGDataProviderCreateWithFilename([sparklePath UTF8String]);
    if(!sparkleSource) {
        invalid_image(stderr, (char *)[sparklePath UTF8String]);
        return;
    }
    CGImageRef sparkleImage = CGImageCreateWithPNGDataProvider(sparkleSource, NULL, true, 0);

    CAEmitterLayer *emitter = getEmitterForImageInFrame(sparkleImage, imageSize);

    [view.layer addSublayer: emitter];

    animateLayerAlongPathForKey(layer, path, @"position");
    animateLayerAlongPathForKey(emitter, path, @"emitterPosition");

    [window makeKeyAndOrderFront: nil];

    // Wait for animation to finish
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow: seconds + 0.2]];

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
    double sec = 2.0;

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
    if (NULL != s) sec = strtod(s, NULL);
    if (! sec > 0.0) sec = 2.0;
    seconds = sec;

    if (verbose) {
        printf("Seconds: %f\n", seconds);
    }

    animateImage();
    return 0;
}
