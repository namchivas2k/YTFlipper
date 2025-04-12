/* How to Hook with Logos
Hooks are written with syntax similar to that of an Objective-C @implementation.
You don't need to #include <substrate.h>, it will be done automatically, as will
the generation of a class list and an automatic constructor.

%hook ClassName

// Hooking a class method
+ (id)sharedInstance {
	return %orig;
}

// Hooking an instance method with an argument.
- (void)messageName:(int)argument {
	%log; // Write a message about this call, including its class, name and arguments, to the system log.

	%orig; // Call through to the original function with its original arguments.
	%orig(nil); // Call through to the original function with a custom argument.

	// If you use %orig(), you MUST supply all arguments (except for self and _cmd, the automatically generated ones.)
}

// Hooking an instance method with no arguments.
- (id)noArguments {
	%log;
	id awesome = %orig;
	[awesome doSomethingElse];

	return awesome;
}

// Always make sure you clean up after yourself; Not doing so could have grave consequences!
%end
*/


#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@interface YTMainVideoPlayerOverlayViewController : UIViewController
- (UIView *)playerView;
@end

@interface VideoFlipTweak : NSObject
@property (nonatomic, assign) BOOL isFlipped;
@property (nonatomic, strong) UIButton *flipButton;
@end

static VideoFlipTweak *tweakInstance;

@implementation VideoFlipTweak
@synthesize isFlipped = _isFlipped;
@synthesize flipButton = _flipButton;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tweakInstance = [[VideoFlipTweak alloc] init];
    });
    return tweakInstance;
}

- (void)toggleFlipForPlayerView:(UIView *)playerView {
    self.isFlipped = !self.isFlipped;
    
    // Access the AVPlayerLayer or equivalent
    for (CALayer *layer in playerView.layer.sublayers) {
        if ([layer isKindOfClass:[objc_getClass("AVPlayerLayer") class]]) {
            CATransform3D transform = self.isFlipped ? CATransform3DMakeScale(-1.0, 1.0, 1.0) : CATransform3DIdentity;
            [CATransaction begin];
            [CATransaction setAnimationDuration:0.3];
            layer.transform = transform;
            [CATransaction commit];
            break;
        }
    }
}

- (void)flipButtonTapped:(UIButton *)sender {
    // Find the player view
    YTMainVideoPlayerOverlayViewController *controller = (YTMainVideoPlayerOverlayViewController *)[sender.superview nextResponder];
    if ([controller isKindOfClass:objc_getClass("YTMainVideoPlayerOverlayViewController")]) {
        [self toggleFlipForPlayerView:[controller playerView]];
    }
}

@end

%hook YTMainVideoPlayerOverlayViewController
- (void)viewDidLoad {
    %orig;

    // Initialize tweak instance
    tweakInstance = [VideoFlipTweak sharedInstance];

    // Create flip button
    UIButton *flipButton = [UIButton buttonWithType:UIButtonTypeCustom];
    flipButton.frame = CGRectMake(20, 20, 40, 40); // Adjust position as needed
    [flipButton setImage:[UIImage imageNamed:@"FlipIcon"] forState:UIControlStateNormal]; // Add icon (see below)
    [flipButton addTarget:tweakInstance action:@selector(flipButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    flipButton.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    flipButton.layer.cornerRadius = 20;
    tweakInstance.flipButton = flipButton;

    // Add button to overlay
    [self.view addSubview:flipButton];
}

- (void)viewDidLayoutSubviews {
    %orig;

    // Adjust button position for landscape/portrait
    CGSize viewSize = self.view.bounds.size;
    tweakInstance.flipButton.frame = CGRectMake(viewSize.width - 60, 20, 40, 40); // Top-right corner
}
%end