//
//  SVProgressHUD.h
//  SVProgressHUD, https://github.com/SVProgressHUD/SVProgressHUD
//
//  Copyright (c) 2011-2016 Sam Vermette and contributors. All rights reserved.
//

#if !__has_feature(objc_arc)
#error SVProgressHUD is ARC only. Either turn on ARC for the project or use -fobjc-arc flag
#endif

#import "SVProgressHUD.h"
#import "SVIndefiniteAnimatedView.h"
#import "SVProgressAnimatedView.h"
#import "SVRadialGradientLayer.h"

NSString * const SVProgressHUDDidReceiveTouchEventNotification = @"SVProgressHUDDidReceiveTouchEventNotification";
NSString * const SVProgressHUDDidTouchDownInsideNotification = @"SVProgressHUDDidTouchDownInsideNotification";
NSString * const SVProgressHUDWillDisappearNotification = @"SVProgressHUDWillDisappearNotification";
NSString * const SVProgressHUDDidDisappearNotification = @"SVProgressHUDDidDisappearNotification";
NSString * const SVProgressHUDWillAppearNotification = @"SVProgressHUDWillAppearNotification";
NSString * const SVProgressHUDDidAppearNotification = @"SVProgressHUDDidAppearNotification";

NSString * const SVProgressHUDStatusUserInfoKey = @"SVProgressHUDStatusUserInfoKey";

static const CGFloat SVProgressHUDParallaxDepthPoints = 10;
static const CGFloat SVProgressHUDUndefinedProgress = -1;
static const CGFloat SVProgressHUDDefaultAnimationDuration = 0.15;

@interface SVProgressHUD ()

@property (nonatomic, strong, readonly) NSTimer *fadeOutTimer;
@property (nonatomic, readonly, getter = isClear) BOOL clear;

@property (nonatomic, strong) UIControl *overlayView;
@property (nonatomic, strong) UIView *hudView;

@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *indefiniteAnimatedView;
@property (nonatomic, strong) SVProgressAnimatedView *ringView;
@property (nonatomic, strong) SVProgressAnimatedView *backgroundRingView;
@property (nonatomic, strong) CALayer *backgroundLayer;

@property (nonatomic, readwrite) CGFloat progress;
@property (nonatomic, readwrite) NSUInteger activityCount;

@property (nonatomic, readonly) CGFloat visibleKeyboardHeight;

- (void)updateHUDFrame;
- (void)updateMask;
- (void)updateBlurBounds;
#if TARGET_OS_IOS
- (void)updateMotionEffectForOrientation:(UIInterfaceOrientation)orientation;
#endif
- (void)updateMotionEffectForXMotionEffectType:(UIInterpolatingMotionEffectType)xMotionEffectType yMotionEffectType:(UIInterpolatingMotionEffectType)yMotionEffectType;
- (void)updateViewHierarchy;

- (void)setStatus:(NSString*)status;
- (void)setFadeOutTimer:(NSTimer*)timer;

- (void)registerNotifications;
- (NSDictionary*)notificationUserInfo;

- (void)positionHUD:(NSNotification*)notification;
- (void)moveToPoint:(CGPoint)newCenter rotateAngle:(CGFloat)angle;

- (void)overlayViewDidReceiveTouchEvent:(id)sender forEvent:(UIEvent*)event;

- (void)showProgress:(float)progress status:(NSString*)status;
- (void)showImage:(UIImage*)image status:(NSString*)status duration:(NSTimeInterval)duration;
- (void)showStatus:(NSString*)status;

- (void)dismiss;
- (void)dismissWithDelay:(NSTimeInterval)delay completion:(SVProgressHUDDismissCompletion)completion;

- (UIView*)indefiniteAnimatedView;
- (SVProgressAnimatedView*)ringView;
- (SVProgressAnimatedView*)backgroundRingView;

- (void)cancelRingLayerAnimation;
- (void)cancelIndefiniteAnimatedViewAnimation;

- (UIColor*)foregroundColorForStyle;
- (UIColor*)backgroundColorForStyle;
- (UIImage*)image:(UIImage*)image withTintColor:(UIColor*)color;

@end


@implementation SVProgressHUD {
    BOOL _isInitializing;
}

+ (SVProgressHUD*)sharedView {
    static dispatch_once_t once;
    
    static SVProgressHUD *sharedView;
#if !defined(SV_APP_EXTENSIONS)
    dispatch_once(&once, ^{ sharedView = [[self alloc] initWithFrame:[[[UIApplication sharedApplication] delegate] window].bounds]; });
#else
    dispatch_once(&once, ^{ sharedView = [[self alloc] initWithFrame:[[UIScreen mainScreen] bounds]]; });
#endif
    return sharedView;
}


#pragma mark - Setters

+ (void)setStatus:(NSString*)status {
    [[self sharedView] setStatus:status];
}

+ (void)setDefaultStyle:(SVProgressHUDStyle)style {
    [self sharedView].defaultStyle = style;
}

+ (void)setDefaultMaskType:(SVProgressHUDMaskType)maskType {
    [self sharedView].defaultMaskType = maskType;
}

+ (void)setDefaultAnimationType:(SVProgressHUDAnimationType)type {
    [self sharedView].defaultAnimationType = type;
}

+ (void)setMinimumSize:(CGSize)minimumSize {
    [self sharedView].minimumSize = minimumSize;
}

+ (void)setRingThickness:(CGFloat)ringThickness {
    [self sharedView].ringThickness = ringThickness;
}

+ (void)setRingRadius:(CGFloat)radius {
    [self sharedView].ringRadius = radius;
}

+ (void)setRingNoTextRadius:(CGFloat)radius {
    [self sharedView].ringNoTextRadius = radius;
}

+ (void)setCornerRadius:(CGFloat)cornerRadius {
    [self sharedView].cornerRadius = cornerRadius;
}

+ (void)setFont:(UIFont*)font {
    [self sharedView].font = font;
}

+ (void)setForegroundColor:(UIColor*)color {
    [self sharedView].foregroundColor = color;
}

+ (void)setBackgroundColor:(UIColor*)color {
    [self sharedView].backgroundColor = color;
}

+ (void)setBackgroundLayerColor:(UIColor*)color {
    [self sharedView].backgroundLayerColor = color;
}

+ (void)setInfoImage:(UIImage*)image {
    [self sharedView].infoImage = image;
}

+ (void)setSuccessImage:(UIImage*)image {
    [self sharedView].successImage = image;
}

+ (void)setErrorImage:(UIImage*)image {
    [self sharedView].errorImage = image;
}

+ (void)setViewForExtension:(UIView*)view {
    [self sharedView].viewForExtension = view;
}

+ (void)setMinimumDismissTimeInterval:(NSTimeInterval)interval {
    [self sharedView].minimumDismissTimeInterval = interval;
}

+ (void)setFadeInAnimationDuration:(NSTimeInterval)duration {
    [self sharedView].fadeInAnimationDuration = duration;
}

+ (void)setFadeOutAnimationDuration:(NSTimeInterval)duration {
    [self sharedView].fadeOutAnimationDuration = duration;
}

+ (void)setMaxSupportedWindowLevel:(UIWindowLevel)windowLevel {
    [self sharedView].maxSupportedWindowLevel = windowLevel;
}

#pragma mark - Show Methods

+ (void)show {
    [self showWithStatus:nil];
}

+ (void)showWithMaskType:(SVProgressHUDMaskType)maskType {
    SVProgressHUDMaskType existingMaskType = [self sharedView].defaultMaskType;
    [self setDefaultMaskType:maskType];
    [self show];
    [self setDefaultMaskType:existingMaskType];
}

+ (void)showWithStatus:(NSString*)status {
    [self sharedView];
    [self showProgress:SVProgressHUDUndefinedProgress status:status];
}

+ (void)showWithStatus:(NSString*)status maskType:(SVProgressHUDMaskType)maskType {
    SVProgressHUDMaskType existingMaskType = [self sharedView].defaultMaskType;
    [self setDefaultMaskType:maskType];
    [self showWithStatus:status];
    [self setDefaultMaskType:existingMaskType];
}

+ (void)showProgress:(float)progress {
    [self showProgress:progress status:nil];
}

+ (void)showProgress:(float)progress maskType:(SVProgressHUDMaskType)maskType {
    SVProgressHUDMaskType existingMaskType = [self sharedView].defaultMaskType;
    [self setDefaultMaskType:maskType];
    [self showProgress:progress];
    [self setDefaultMaskType:existingMaskType];
}

+ (void)showProgress:(float)progress status:(NSString*)status {
    [[self sharedView] showProgress:progress status:status];
}

+ (void)showProgress:(float)progress status:(NSString*)status maskType:(SVProgressHUDMaskType)maskType {
    SVProgressHUDMaskType existingMaskType = [self sharedView].defaultMaskType;
    [self setDefaultMaskType:maskType];
    [self showProgress:progress status:status];
    [self setDefaultMaskType:existingMaskType];
}


#pragma mark - Show, then automatically dismiss methods

+ (void)showInfoWithStatus:(NSString*)status {
    [self showImage:[self sharedView].infoImage status:status];
}

+ (void)showInfoWithStatus:(NSString*)status maskType:(SVProgressHUDMaskType)maskType {
    SVProgressHUDMaskType existingMaskType = [self sharedView].defaultMaskType;
    [self setDefaultMaskType:maskType];
    [self showInfoWithStatus:status];
    [self setDefaultMaskType:existingMaskType];
}

+ (void)showSuccessWithStatus:(NSString*)status {
    [self showImage:[self sharedView].successImage status:status];
}

+ (void)showSuccessWithStatus:(NSString*)status maskType:(SVProgressHUDMaskType)maskType {
    SVProgressHUDMaskType existingMaskType = [self sharedView].defaultMaskType;
    [self setDefaultMaskType:maskType];
    [self showSuccessWithStatus:status];
    [self setDefaultMaskType:existingMaskType];
}

+ (void)showErrorWithStatus:(NSString*)status {
    [self showImage:[self sharedView].errorImage status:status];
}

+ (void)showErrorWithStatus:(NSString*)status maskType:(SVProgressHUDMaskType)maskType {
    SVProgressHUDMaskType existingMaskType = [self sharedView].defaultMaskType;
    [self setDefaultMaskType:maskType];
    [self showErrorWithStatus:status];
    [self setDefaultMaskType:existingMaskType];
}

+ (void)showImage:(UIImage*)image status:(NSString*)status {
    NSTimeInterval displayInterval = [self displayDurationForString:status];
    [[self sharedView] showImage:image status:status duration:displayInterval];
}

+ (void)showImage:(UIImage*)image status:(NSString*)status maskType:(SVProgressHUDMaskType)maskType {
    SVProgressHUDMaskType existingMaskType = [self sharedView].defaultMaskType;
    [self setDefaultMaskType:maskType];
    [self showImage:image status:status];
    [self setDefaultMaskType:existingMaskType];
}


#pragma mark - Dismiss Methods

+ (void)popActivity {
    if([self sharedView].activityCount > 0) {
        [self sharedView].activityCount--;
    }
    if([self sharedView].activityCount == 0) {
        [[self sharedView] dismiss];
    }
}

+ (void)dismiss {
    [self dismissWithDelay:0.0 completion:nil];
}

+ (void)dismissWithCompletion:(SVProgressHUDDismissCompletion)completion {
    [self dismissWithDelay:0.0 completion:completion];
}

+ (void)dismissWithDelay:(NSTimeInterval)delay {
    [self dismissWithDelay:delay completion:nil];
}

+ (void)dismissWithDelay:(NSTimeInterval)delay completion:(SVProgressHUDDismissCompletion)completion {
    [[self sharedView] dismissWithDelay:delay completion:completion];
}


#pragma mark - Offset

+ (void)setOffsetFromCenter:(UIOffset)offset {
    [self sharedView].offsetFromCenter = offset;
}

+ (void)resetOffsetFromCenter {
    [self setOffsetFromCenter:UIOffsetZero];
}


#pragma mark - Instance Methods

- (instancetype)initWithFrame:(CGRect)frame {
    if((self = [super initWithFrame:frame])) {
        _isInitializing = YES;
        
        self.userInteractionEnabled = NO;
        _backgroundColor = [UIColor clearColor];
        _foregroundColor = [UIColor blackColor];
        _backgroundLayerColor = [UIColor colorWithWhite:0 alpha:0.4];
        
        self.alpha = 0.0f;
        self.activityCount = 0;
        
        // Set default values
        _defaultMaskType = SVProgressHUDMaskTypeNone;
        _defaultStyle = SVProgressHUDStyleLight;
        _defaultAnimationType = SVProgressHUDAnimationTypeFlat;
        _minimumSize = CGSizeMake(100.0f, 100.0f);
        
        if ([UIFont respondsToSelector:@selector(preferredFontForTextStyle:)]) {
            _font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        } else {
            _font = [UIFont systemFontOfSize:14.0f];
        }
        
        NSBundle *bundle = [NSBundle bundleForClass:[SVProgressHUD class]];
        NSURL *url = [bundle URLForResource:@"SVProgressHUD" withExtension:@"bundle"];
        NSBundle *imageBundle = [NSBundle bundleWithURL:url];
        
        UIImage* infoImage = [UIImage imageWithContentsOfFile:[imageBundle pathForResource:@"info" ofType:@"png"]];
        UIImage* successImage = [UIImage imageWithContentsOfFile:[imageBundle pathForResource:@"success" ofType:@"png"]];
        UIImage* errorImage = [UIImage imageWithContentsOfFile:[imageBundle pathForResource:@"error" ofType:@"png"]];

        if ([[UIImage class] instancesRespondToSelector:@selector(imageWithRenderingMode:)]) {
            _infoImage = [infoImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            _successImage = [successImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            _errorImage = [errorImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        } else {
            _infoImage = infoImage;
            _successImage = successImage;
            _errorImage = errorImage;
        }

        _ringThickness = 2.0f;
        _ringRadius = 18.0f;
        _ringNoTextRadius = 24.0f;
        
        _cornerRadius = 14.0f;
        
        _minimumDismissTimeInterval = 5.0;

        _fadeInAnimationDuration = SVProgressHUDDefaultAnimationDuration;
        _fadeOutAnimationDuration = SVProgressHUDDefaultAnimationDuration;
        
        _maxSupportedWindowLevel = UIWindowLevelNormal;
        
        // Accessibility support
        self.accessibilityIdentifier = @"SVProgressHUD";
        self.accessibilityLabel = @"SVProgressHUD";
        self.isAccessibilityElement = YES;
        
        _isInitializing = NO;
    }
    return self;
}

- (void)updateHUDFrame {
    // For the beginning use default values, these
    // might get update if string is too large etc.
    CGFloat hudWidth = 0.0f;
    CGFloat hudHeight = 0.0f;
    CGRect labelRect = CGRectZero;
    
    CGFloat verticalSpacing = 12.0f; // |-12-content-(8-label-)12-|
    CGFloat horizontalSpacing = 12.0f; // |-12-content-12-|
    CGFloat progressLabelSpacing = 8.0f; // content-8-label; progess = spinner or image
    
    // Check if an image or progress ring is displayed
    BOOL imageUsed = (self.imageView.image) && !(self.imageView.hidden);
    BOOL progressUsed = self.imageView.hidden;
    
    // Calculate size of string and update HUD size
    NSString *string = self.statusLabel.text;
    if(string) {
        CGSize constraintSize = CGSizeMake(200.0f, 300.0f);
        if([string respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
            labelRect = [string boundingRectWithSize:constraintSize
                                             options:(NSStringDrawingOptions)(NSStringDrawingUsesFontLeading|NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin)
                                          attributes:@{NSFontAttributeName: self.statusLabel.font}
                                             context:NULL];
        } else {
            CGSize stringSize;
            if([string respondsToSelector:@selector(sizeWithAttributes:)]) {
                stringSize = [string sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:self.statusLabel.font.fontName size:self.statusLabel.font.pointSize]}];
            } else {
#if TARGET_OS_IOS
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
                stringSize = [string sizeWithFont:self.statusLabel.font constrainedToSize:CGSizeMake(200.0f, 300.0f)];
#pragma clang diagnostic pop
#endif
            }
            labelRect = CGRectMake(0.0f, 0.0f, stringSize.width, stringSize.height);
        }
        labelRect.size.width = MAX(self.minimumSize.width, horizontalSpacing + CGRectGetWidth(labelRect) + horizontalSpacing);
        
        CGFloat labelHeight = ceilf(CGRectGetHeight(labelRect));
        CGFloat labelWidth = ceilf(CGRectGetWidth(labelRect));
        
        if(imageUsed || progressUsed) {
            CGFloat contentHeight = (imageUsed ? CGRectGetHeight(self.imageView.frame) : CGRectGetHeight(self.indefiniteAnimatedView.frame));
            hudHeight = verticalSpacing + contentHeight + progressLabelSpacing + labelHeight + verticalSpacing;
        } else {
            hudHeight = verticalSpacing + labelHeight + verticalSpacing;
        }
        hudWidth = labelWidth;
    }
    
    // Update values on subviews
    self.hudView.bounds = CGRectMake(0.0f, 0.0f, MAX(self.minimumSize.width, hudWidth), MAX(self.minimumSize.height, hudHeight));
    [self updateBlurBounds];
    
    // Animate value update
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    // Spinner and image view
    CGFloat centerY;
    if(string){
        CGFloat contentHeight = (imageUsed ? CGRectGetHeight(self.imageView.frame) : CGRectGetHeight(self.indefiniteAnimatedView.frame));
        CGFloat labelHeight = ceilf(CGRectGetHeight(labelRect));
        CGFloat yOffset = MAX(verticalSpacing, (self.minimumSize.height - contentHeight - progressLabelSpacing - labelHeight) / 2.0f);
        
        centerY = yOffset + contentHeight / 2.0f;
    } else {
        centerY = CGRectGetHeight(self.hudView.bounds) / 2.0f;
    }
    self.indefiniteAnimatedView.center = CGPointMake((CGRectGetWidth(self.hudView.bounds) / 2.0f), centerY);
    if(self.progress != SVProgressHUDUndefinedProgress) {
        self.backgroundRingView.center = self.ringView.center = CGPointMake((CGRectGetWidth(self.hudView.bounds) / 2.0f), centerY);
    }
    self.imageView.center = CGPointMake(CGRectGetWidth(self.hudView.bounds) / 2.0f, centerY);

    // Label
    if(imageUsed || progressUsed){
        labelRect.origin.y = (imageUsed ? CGRectGetMaxY(self.imageView.frame) : CGRectGetMaxY(self.indefiniteAnimatedView.frame)) + progressLabelSpacing;
    } else {
        labelRect.origin.y = verticalSpacing;
    }
    self.statusLabel.frame = labelRect;
    self.statusLabel.hidden = !string;
    
    [CATransaction commit];
}

- (void)updateMask {
    if(self.backgroundLayer) {
        [self.backgroundLayer removeFromSuperlayer];
        self.backgroundLayer = nil;
    }
    switch (self.defaultMaskType) {
        case SVProgressHUDMaskTypeCustom:
        case SVProgressHUDMaskTypeBlack:{
            
            self.backgroundLayer = [CALayer layer];
            self.backgroundLayer.frame = self.bounds;
            self.backgroundLayer.backgroundColor = self.defaultMaskType == SVProgressHUDMaskTypeCustom ? self.backgroundLayerColor.CGColor : [UIColor colorWithWhite:0 alpha:0.4].CGColor;
            [self.backgroundLayer setNeedsDisplay];
            
            [self.layer insertSublayer:self.backgroundLayer atIndex:0];
            break;
        }
            
        case SVProgressHUDMaskTypeGradient:{
            SVRadialGradientLayer *layer = [SVRadialGradientLayer layer];
            self.backgroundLayer = layer;
            self.backgroundLayer.frame = self.bounds;
            CGPoint gradientCenter = self.center;
            gradientCenter.y = (self.bounds.size.height - self.visibleKeyboardHeight)/2;
            layer.gradientCenter = gradientCenter;
            [self.backgroundLayer setNeedsDisplay];
            
            [self.layer insertSublayer:self.backgroundLayer atIndex:0];
            break;
        }
        default:
            break;
    }
}

- (void)updateBlurBounds {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    if(NSClassFromString(@"UIBlurEffect") && self.defaultStyle != SVProgressHUDStyleCustom) {
        // Remove any old instances of UIVisualEffectViews
        for (UIView *subview in self.hudView.subviews) {
            if([subview isKindOfClass:[UIVisualEffectView class]]) {
                [subview removeFromSuperview];
            }
        }
        
        if(self.backgroundColorForStyle != [UIColor clearColor]) {
            // Create blur effect
            UIBlurEffectStyle blurEffectStyle = self.defaultStyle == SVProgressHUDStyleDark ? UIBlurEffectStyleDark : UIBlurEffectStyleLight;
            UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:blurEffectStyle];
            UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
            blurEffectView.autoresizingMask = self.hudView.autoresizingMask;
            blurEffectView.frame = self.hudView.bounds;
            
            // Add vibrancy to the blur effect to make it more vivid
            UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:blurEffect];
            UIVisualEffectView *vibrancyEffectView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
            vibrancyEffectView.autoresizingMask = blurEffectView.autoresizingMask;
            vibrancyEffectView.bounds = blurEffectView.bounds;
            [blurEffectView.contentView addSubview:vibrancyEffectView];
            
            [self.hudView insertSubview:blurEffectView atIndex:0];
        }
    } else{
        // Remove any old instances of UIVisualEffectViews, when the HUDStyle changed from other to custom
        for (UIView *subview in self.hudView.subviews) {
            if([subview isKindOfClass:[UIVisualEffectView class]]) {
                [subview removeFromSuperview];
            }
        }
    }
#endif
}

#if TARGET_OS_IOS
- (void)updateMotionEffectForOrientation:(UIInterfaceOrientation)orientation {
    UIInterpolatingMotionEffectType xMotionEffectType = UIInterfaceOrientationIsPortrait(orientation) ? UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis : UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis;
    UIInterpolatingMotionEffectType yMotionEffectType = UIInterfaceOrientationIsPortrait(orientation) ? UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis : UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis;
    [self updateMotionEffectForXMotionEffectType:xMotionEffectType yMotionEffectType:yMotionEffectType];
}
#endif

- (void)updateMotionEffectForXMotionEffectType:(UIInterpolatingMotionEffectType)xMotionEffectType yMotionEffectType:(UIInterpolatingMotionEffectType)yMotionEffectType {
    if([self.hudView respondsToSelector:@selector(addMotionEffect:)]) {
        UIInterpolatingMotionEffect *effectX = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:xMotionEffectType];
        effectX.minimumRelativeValue = @(-SVProgressHUDParallaxDepthPoints);
        effectX.maximumRelativeValue = @(SVProgressHUDParallaxDepthPoints);
        
        UIInterpolatingMotionEffect *effectY = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:yMotionEffectType];
        effectY.minimumRelativeValue = @(-SVProgressHUDParallaxDepthPoints);
        effectY.maximumRelativeValue = @(SVProgressHUDParallaxDepthPoints);
        
        UIMotionEffectGroup *effectGroup = [[UIMotionEffectGroup alloc] init];
        effectGroup.motionEffects = @[effectX, effectY];
        
        // Clear old motion effect, then add new motion effects
        self.hudView.motionEffects = @[];
        [self.hudView addMotionEffect:effectGroup];
    }
}

- (void)updateViewHierarchy {
    // Add the overlay (e.g. black, gradient) to the application window if necessary
    if(!self.overlayView.superview) {
#if !defined(SV_APP_EXTENSIONS)
        // Default case: iterate over UIApplication windows
        NSEnumerator *frontToBackWindows = [UIApplication.sharedApplication.windows reverseObjectEnumerator];
        for (UIWindow *window in frontToBackWindows) {
            BOOL windowOnMainScreen = window.screen == UIScreen.mainScreen;
            BOOL windowIsVisible = !window.hidden && window.alpha > 0;
            BOOL windowLevelSupported = (window.windowLevel >= UIWindowLevelNormal && window.windowLevel <= self.maxSupportedWindowLevel);
            
            if(windowOnMainScreen && windowIsVisible && windowLevelSupported) {
                [window addSubview:self.overlayView];
                break;
            }
        }
#else
        // If SVProgressHUD ist used inside an app extension add it to the given view
        if(self.viewForExtension) {
            [self.viewForExtension addSubview:self.overlayView];
        }
#endif
    } else {
        // The HUD is already on screen, but maybot not in front. Therefore
        // ensure that overlay will be on top of rootViewController (which may
        // be changed during runtime).
        [self.overlayView.superview bringSubviewToFront:self.overlayView];
    }
    
    
    // Add self to the overlay view
    if(!self.superview){
        [self.overlayView addSubview:self];
    }
    if(!self.hudView.superview) {
        [self addSubview:self.hudView];
    }
}

- (void)setStatus:(NSString*)status {
    self.statusLabel.text = status;
    [self updateHUDFrame];
}

- (void)setFadeOutTimer:(NSTimer*)timer {
    if(_fadeOutTimer) {
        [_fadeOutTimer invalidate], _fadeOutTimer = nil;
    }
    if(timer) {
        _fadeOutTimer = timer;
    }
}


#pragma mark - Notifications and their handling

- (void)registerNotifications {
#if TARGET_OS_IOS
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(positionHUD:)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(positionHUD:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(positionHUD:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(positionHUD:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(positionHUD:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
#endif
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(positionHUD:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

- (NSDictionary*)notificationUserInfo{
    return (self.statusLabel.text ? @{SVProgressHUDStatusUserInfoKey : self.statusLabel.text} : nil);
}

- (void)positionHUD:(NSNotification*)notification {
    CGFloat keyboardHeight = 0.0f;
    double animationDuration = 0.0;

#if !defined(SV_APP_EXTENSIONS) && TARGET_OS_IOS
    self.frame = [[[UIApplication sharedApplication] delegate] window].bounds;
    UIInterfaceOrientation orientation = UIApplication.sharedApplication.statusBarOrientation;
#elif !defined(SV_APP_EXTENSIONS) && !TARGET_OS_IOS
    self.frame= [UIApplication sharedApplication].keyWindow.bounds;
#else
    if (self.viewForExtension) {
        self.frame = self.viewForExtension.frame;
    } else {
        self.frame = UIScreen.mainScreen.bounds;
    }
#if TARGET_OS_IOS
    UIInterfaceOrientation orientation = CGRectGetWidth(self.frame) > CGRectGetHeight(self.frame) ? UIInterfaceOrientationLandscapeLeft : UIInterfaceOrientationPortrait;
#endif
#endif
    
    // no transforms applied to window in iOS 8, but only if compiled with iOS 8 sdk as base sdk, otherwise system supports old rotation logic.
    BOOL ignoreOrientation = NO;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    if([[NSProcessInfo processInfo] respondsToSelector:@selector(operatingSystemVersion)]) {
        ignoreOrientation = YES;
    }
#endif
    
#if TARGET_OS_IOS
    // Get keyboardHeight in regards to current state
    if(notification) {
        NSDictionary* keyboardInfo = [notification userInfo];
        CGRect keyboardFrame = [keyboardInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
        animationDuration = [keyboardInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        
        if(notification.name == UIKeyboardWillShowNotification || notification.name == UIKeyboardDidShowNotification) {
            keyboardHeight = CGRectGetWidth(keyboardFrame);

            if(ignoreOrientation || UIInterfaceOrientationIsPortrait(orientation)) {
                keyboardHeight = CGRectGetHeight(keyboardFrame);
            }
        }
    } else {
        keyboardHeight = self.visibleKeyboardHeight;
    }
#endif
    
    // Get the currently active frame of the display (depends on orientation)
    CGRect orientationFrame = self.bounds;

#if !defined(SV_APP_EXTENSIONS) && TARGET_OS_IOS
    CGRect statusBarFrame = UIApplication.sharedApplication.statusBarFrame;
#else
    CGRect statusBarFrame = CGRectZero;
#endif
    
#if TARGET_OS_IOS
    if(!ignoreOrientation && UIInterfaceOrientationIsLandscape(orientation)) {
        float temp = CGRectGetWidth(orientationFrame);
        orientationFrame.size.width = CGRectGetHeight(orientationFrame);
        orientationFrame.size.height = temp;
        
        temp = CGRectGetWidth(statusBarFrame);
        statusBarFrame.size.width = CGRectGetHeight(statusBarFrame);
        statusBarFrame.size.height = temp;
    }
    
    // Update the motion effects in regards to orientation
    [self updateMotionEffectForOrientation:orientation];
#else
    [self updateMotionEffectForXMotionEffectType:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis yMotionEffectType:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
#endif
    
    // Calculate available height for display
    CGFloat activeHeight = CGRectGetHeight(orientationFrame);
    if(keyboardHeight > 0) {
        activeHeight += CGRectGetHeight(statusBarFrame)*2;
    }
    activeHeight -= keyboardHeight;
    
    CGFloat posX = CGRectGetWidth(orientationFrame)/2.0f;
    CGFloat posY = floorf(activeHeight*0.45f);

    CGFloat rotateAngle = 0.0;
    CGPoint newCenter = CGPointMake(posX, posY);
    
    // Update posX and posY in regards to orientation
#if TARGET_OS_IOS
    if(!ignoreOrientation) {
        switch (orientation) {
            case UIInterfaceOrientationPortraitUpsideDown:
                rotateAngle = (CGFloat) M_PI;
                newCenter = CGPointMake(posX, CGRectGetHeight(orientationFrame)-posY);
                break;
            case UIInterfaceOrientationLandscapeLeft:
                rotateAngle = (CGFloat) (-M_PI/2.0f);
                newCenter = CGPointMake(posY, posX);
                break;
            case UIInterfaceOrientationLandscapeRight:
                rotateAngle = (CGFloat) (M_PI/2.0f);
                newCenter = CGPointMake(CGRectGetHeight(orientationFrame)-posY, posX);
                break;
            default: // Same as UIInterfaceOrientationPortrait
                rotateAngle = 0.0f;
                newCenter = CGPointMake(posX, posY);
                break;
        }
    }
#endif
    
    if(notification) {
        // Animate update if notification was present
        __weak SVProgressHUD *weakSelf = self;
        [UIView animateWithDuration:animationDuration
                              delay:0
                            options:(UIViewAnimationOptions) (UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState)
                         animations:^{
                             __strong SVProgressHUD *strongSelf = weakSelf;
                             if(strongSelf) {
                                 [strongSelf moveToPoint:newCenter rotateAngle:rotateAngle];
                                 [strongSelf.hudView setNeedsDisplay];
                             }
                         } completion:NULL];
    } else {
        [self moveToPoint:newCenter rotateAngle:rotateAngle];
        [self.hudView setNeedsDisplay];
    }
    
    [self updateMask];
}

- (void)moveToPoint:(CGPoint)newCenter rotateAngle:(CGFloat)angle {
    self.hudView.transform = CGAffineTransformMakeRotation(angle);
    self.hudView.center = CGPointMake(newCenter.x + self.offsetFromCenter.horizontal, newCenter.y + self.offsetFromCenter.vertical);
}


#pragma mark - Event handling

- (void)overlayViewDidReceiveTouchEvent:(id)sender forEvent:(UIEvent*)event {
    [[NSNotificationCenter defaultCenter] postNotificationName:SVProgressHUDDidReceiveTouchEventNotification
                                                        object:self
                                                      userInfo:[self notificationUserInfo]];
    
    UITouch *touch = event.allTouches.anyObject;
    CGPoint touchLocation = [touch locationInView:self];
    
    if(CGRectContainsPoint(self.hudView.frame, touchLocation)) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SVProgressHUDDidTouchDownInsideNotification
                                                            object:self
                                                          userInfo:[self notificationUserInfo]];
    }
}


#pragma mark - Master show/dismiss methods

- (void)showProgress:(float)progress status:(NSString*)status {
    __weak SVProgressHUD *weakSelf = self;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        __strong SVProgressHUD *strongSelf = weakSelf;
        if(strongSelf){
            // Update / Check view hierarchy to ensure the HUD is visible
            [strongSelf updateViewHierarchy];
            
            // Reset imageView and fadeout timer if an image is currently displayed
            strongSelf.imageView.hidden = YES;
            strongSelf.imageView.image = nil;
            
            if(strongSelf.fadeOutTimer) {
                strongSelf.activityCount = 0;
            }
            strongSelf.fadeOutTimer = nil;
            
            // Update text and set progress to the given value
            strongSelf.statusLabel.text = status;
            strongSelf.progress = progress;
            
            // Choose the "right" indicator depending on the progress
            if(progress >= 0) {
                // Cancel the indefiniteAnimatedView, then show the ringLayer
                [strongSelf cancelIndefiniteAnimatedViewAnimation];
                
                // Add ring to HUD
                if(!strongSelf.ringView.superview)
                    [strongSelf.hudView addSubview:strongSelf.ringView];
                if(!strongSelf.backgroundRingView.superview)
                    [strongSelf.hudView addSubview:strongSelf.backgroundRingView];
                
                // Set progress animated
                [CATransaction begin];
                [CATransaction setDisableActions:YES];
                strongSelf.ringView.strokeEnd = progress;
                [CATransaction commit];
                
                // Update the activity count
                if(progress == 0) {
                    strongSelf.activityCount++;
                }
            } else {
                // Cancel the ringLayer animation, then show the indefiniteAnimatedView
                [strongSelf cancelRingLayerAnimation];
                
                // Add indefiniteAnimatedView to HUD
                [strongSelf.hudView addSubview:strongSelf.indefiniteAnimatedView];
                if([strongSelf.indefiniteAnimatedView respondsToSelector:@selector(startAnimating)]) {
                    [(id)strongSelf.indefiniteAnimatedView startAnimating];
                }
                
                // Update the activity count
                strongSelf.activityCount++;
            }
            
            // Show
            [strongSelf showStatus:status];
        }
    }];
}

- (void)showImage:(UIImage*)image status:(NSString*)status duration:(NSTimeInterval)duration {
    __weak SVProgressHUD *weakSelf = self;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        __strong SVProgressHUD *strongSelf = weakSelf;
        if(strongSelf){
            // Update / Check view hierarchy to ensure the HUD is visible
            [strongSelf updateViewHierarchy];
            
            // Reset progress and cancel any running animation
            strongSelf.progress = SVProgressHUDUndefinedProgress;
            [strongSelf cancelRingLayerAnimation];
            [strongSelf cancelIndefiniteAnimatedViewAnimation];
            
            // Update imageView
            UIColor *tintColor = strongSelf.foregroundColorForStyle;
            UIImage *tintedImage = image;
            if([strongSelf.imageView respondsToSelector:@selector(setTintColor:)]) {
                if (tintedImage.renderingMode != UIImageRenderingModeAlwaysTemplate) {
                    tintedImage = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                }
                strongSelf.imageView.tintColor = tintColor;
            } else {
                tintedImage = [strongSelf image:image withTintColor:tintColor];
            }
            strongSelf.imageView.image = tintedImage;
            strongSelf.imageView.hidden = NO;
            
            // Update text
            strongSelf.statusLabel.text = status;
            
            // Show
            [strongSelf showStatus:status];
            
            // An image will dismissed automatically. Therefore we start a timer
            // which then will call dismiss after the predefined duration
            strongSelf.fadeOutTimer = [NSTimer timerWithTimeInterval:duration target:strongSelf selector:@selector(dismiss) userInfo:nil repeats:NO];
            [[NSRunLoop mainRunLoop] addTimer:strongSelf.fadeOutTimer forMode:NSRunLoopCommonModes];
        }
    }];
}

- (void)showStatus:(NSString*)status {
    // Update the HUDs frame to the new content and position HUD
    [self updateHUDFrame];
    [self positionHUD:nil];
    
    // Update accessibility as well as user interaction
    if(self.defaultMaskType != SVProgressHUDMaskTypeNone) {
        self.overlayView.userInteractionEnabled = YES;
        self.accessibilityLabel = status;
        self.isAccessibilityElement = YES;
    } else {
        self.overlayView.userInteractionEnabled = NO;
        self.hudView.accessibilityLabel = status;
        self.hudView.isAccessibilityElement = YES;
    }
    
    // Show overlay
    self.overlayView.backgroundColor = [UIColor clearColor];
    
    // Show if not already visible (depending on alpha)
    if(self.alpha != 1.0f || self.hudView.alpha != 1.0f) {
        // Post notification to inform user
        [[NSNotificationCenter defaultCenter] postNotificationName:SVProgressHUDWillAppearNotification
                                                            object:self
                                                          userInfo:[self notificationUserInfo]];
        
        // Zoom HUD a little to make a nice appear / pop up animation
        self.hudView.transform = CGAffineTransformScale(self.hudView.transform, 1.3, 1.3);
        
        // Set initial values to handle iOS 7 (and above) UIToolbar which not answers well to hierarchy opacity change
        self.alpha = 0.0f;
        self.hudView.alpha = 0.0f;
        
        // Define blocks
        __weak SVProgressHUD *weakSelf = self;
        
        __block void (^animationsBlock)(void) = ^{
            __strong SVProgressHUD *strongSelf = weakSelf;
            if(strongSelf) {
                // Shrink HUD to finish pop up animation
                strongSelf.hudView.transform = CGAffineTransformScale(strongSelf.hudView.transform, 1/1.3f, 1/1.3f);
                strongSelf.alpha = 1.0f;
                strongSelf.hudView.alpha = 1.0f;
            }
        };
        
        __block void (^completionBlock)(void) = ^{
            __strong SVProgressHUD *strongSelf = weakSelf;
            if(strongSelf) {
                // Check if we really achieved to show the HUD (<=> alpha values are applied)
                // and the change of these values has not been cancelled in between
                // e.g. due to a dismissal
                if(strongSelf.alpha == 1.0f && strongSelf.hudView.alpha == 1.0f){
                    // Register observer <=> we now have to handle orientation changes etc.
                    [strongSelf registerNotifications];
                    
                    // Post notification to inform user
                    [[NSNotificationCenter defaultCenter] postNotificationName:SVProgressHUDDidAppearNotification
                                                                        object:strongSelf
                                                                      userInfo:[strongSelf notificationUserInfo]];
                }
            }
            
            // Update accessibility
            UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
            UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, status);
        };
        
        if (self.fadeInAnimationDuration > 0) {
            // Animate appearance
            [UIView animateWithDuration:self.fadeInAnimationDuration
                                  delay:0
                                options:(UIViewAnimationOptions) (UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState)
                             animations:^{
                                 animationsBlock();
                             } completion:^(BOOL finished) {
                                 completionBlock();
                             }];
        } else {
            animationsBlock();
            completionBlock();
        }
        
        // Inform iOS to redraw the view hierarchy
        [self setNeedsDisplay];
    }
}

- (void)dismiss {
    [self dismissWithDelay:0.0 completion:nil];
}

- (void)dismissWithDelay:(NSTimeInterval)delay completion:(SVProgressHUDDismissCompletion)completion {
    __weak SVProgressHUD *weakSelf = self;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        __strong SVProgressHUD *strongSelf = weakSelf;
        if(strongSelf){
            // Post notification to inform user
            [[NSNotificationCenter defaultCenter] postNotificationName:SVProgressHUDWillDisappearNotification
                                                                object:nil
                                                              userInfo:[strongSelf notificationUserInfo]];
            
            // Reset activity count
            strongSelf.activityCount = 0;
            
            // Define blocks
            __block void (^animationsBlock)(void) = ^{
                strongSelf.hudView.transform = CGAffineTransformScale(strongSelf.hudView.transform, 1/1.3f, 1/1.3f);
                strongSelf.alpha = 0.0f;
                strongSelf.hudView.alpha = 0.0f;
            };
            
            __block void (^completionBlock)(void) = ^{
                // Check if we really achieved to dismiss the HUD (<=> alpha values are applied)
                // and the change of these values has not been cancelled in between
                // e.g. due to a new show
                if(strongSelf.alpha == 0.0f && strongSelf.hudView.alpha == 0.0f){
                    // Clean up view hierarchy (overlays)
                    [strongSelf.overlayView removeFromSuperview];
                    [strongSelf.hudView removeFromSuperview];
                    [strongSelf removeFromSuperview];
                    
                    // Reset progress and cancel any running animation
                    strongSelf.progress = SVProgressHUDUndefinedProgress;
                    [strongSelf cancelRingLayerAnimation];
                    [strongSelf cancelIndefiniteAnimatedViewAnimation];
                    
                    // Remove observer <=> we do not have to handle orientation changes etc.
                    [[NSNotificationCenter defaultCenter] removeObserver:strongSelf];
                    
                    // Post notification to inform user
                    [[NSNotificationCenter defaultCenter] postNotificationName:SVProgressHUDDidDisappearNotification
                                                                        object:strongSelf
                                                                      userInfo:[strongSelf notificationUserInfo]];
                    
                    // Tell the rootViewController to update the StatusBar appearance
#if !defined(SV_APP_EXTENSIONS) && TARGET_OS_IOS
                    UIViewController *rootController = [[UIApplication sharedApplication] keyWindow].rootViewController;
                    if([rootController respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
                        [rootController setNeedsStatusBarAppearanceUpdate];
                    }
#endif
                    // Update accessibility
                    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
                    
                    // Run an (optional) completionHandler
                    if (completion) {
                        completion();
                    }
                }
            };
            
            if (strongSelf.fadeOutAnimationDuration > 0) {
                // Animate appearance
                [UIView animateWithDuration:strongSelf.fadeOutAnimationDuration
                                      delay:delay
                                    options:(UIViewAnimationOptions) (UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState)
                                 animations:^{
                                     animationsBlock();
                                 } completion:^(BOOL finished) {
                                     completionBlock();
                                 }];
            } else {
                animationsBlock();
                completionBlock();
            }
            
            // Inform iOS to redraw the view hierarchy
            [strongSelf setNeedsDisplay];
        } else if (completion) {
            // Run an (optional) completionHandler
            completion();
        }
    }];
}


#pragma mark - Ring progress animation

- (UIView*)indefiniteAnimatedView {
    // Get the correct spinner for defaultAnimationType
    if(self.defaultAnimationType == SVProgressHUDAnimationTypeFlat){
        // Check if spinner exists and is an object of different class
        if(_indefiniteAnimatedView && ![_indefiniteAnimatedView isKindOfClass:[SVIndefiniteAnimatedView class]]){
            [_indefiniteAnimatedView removeFromSuperview];
            _indefiniteAnimatedView = nil;
        }
        
        if(!_indefiniteAnimatedView){
            _indefiniteAnimatedView = [[SVIndefiniteAnimatedView alloc] initWithFrame:CGRectZero];
        }
        
        // Update styling
        SVIndefiniteAnimatedView *indefiniteAnimatedView = (SVIndefiniteAnimatedView*)_indefiniteAnimatedView;
        indefiniteAnimatedView.strokeColor = self.foregroundColorForStyle;
        indefiniteAnimatedView.strokeThickness = self.ringThickness;
        indefiniteAnimatedView.radius = self.statusLabel.text ? self.ringRadius : self.ringNoTextRadius;
    } else {
        // Check if spinner exists and is an object of different class
        if(_indefiniteAnimatedView && ![_indefiniteAnimatedView isKindOfClass:[UIActivityIndicatorView class]]){
            [_indefiniteAnimatedView removeFromSuperview];
            _indefiniteAnimatedView = nil;
        }
        
        if(!_indefiniteAnimatedView){
            _indefiniteAnimatedView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        }
        
        // Update styling
        UIActivityIndicatorView *activityIndicatorView = (UIActivityIndicatorView*)_indefiniteAnimatedView;
        activityIndicatorView.color = self.foregroundColorForStyle;
    }
    [_indefiniteAnimatedView sizeToFit];
    
    return _indefiniteAnimatedView;
}

- (SVProgressAnimatedView*)ringView {
    if(!_ringView) {
        _ringView = [[SVProgressAnimatedView alloc] initWithFrame:CGRectZero];
    }
    
    // Update styling
    _ringView.strokeColor = self.foregroundColorForStyle;
    _ringView.strokeThickness = self.ringThickness;
    _ringView.radius = self.statusLabel.text ? self.ringRadius : self.ringNoTextRadius;
    
    return _ringView;
}

- (SVProgressAnimatedView*)backgroundRingView {
    if(!_backgroundRingView) {
        _backgroundRingView = [[SVProgressAnimatedView alloc] initWithFrame:CGRectZero];
        _backgroundRingView.strokeEnd = 1.0f;
    }
    
    // Update styling
    _backgroundRingView.strokeColor = [self.foregroundColorForStyle colorWithAlphaComponent:0.1f];
    _backgroundRingView.strokeThickness = self.ringThickness;
    _backgroundRingView.radius = self.statusLabel.text ? self.ringRadius : self.ringNoTextRadius;
    
    return _backgroundRingView;
}

- (void)cancelRingLayerAnimation {
    // Animate value update, stop animation
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    [self.hudView.layer removeAllAnimations];
    self.ringView.strokeEnd = 0.0f;
    
    [CATransaction commit];
    
    // Remove from view
    [self.ringView removeFromSuperview];
    [self.backgroundRingView removeFromSuperview];
}

- (void)cancelIndefiniteAnimatedViewAnimation {
    // Stop animation
    if([self.indefiniteAnimatedView respondsToSelector:@selector(stopAnimating)]) {
        [(id)self.indefiniteAnimatedView stopAnimating];
    }
    // Remove from view
    [self.indefiniteAnimatedView removeFromSuperview];
}


#pragma mark - Utilities

+ (BOOL)isVisible {
    return ([self sharedView].alpha > 0);
}


#pragma mark - Getters

+ (NSTimeInterval)displayDurationForString:(NSString*)string {
    return MAX((float)string.length * 0.06 + 0.5, [self sharedView].minimumDismissTimeInterval);
}

- (UIColor*)foregroundColorForStyle {
    if(self.defaultStyle == SVProgressHUDStyleLight) {
        return [UIColor blackColor];
    } else if(self.defaultStyle == SVProgressHUDStyleDark) {
        return [UIColor whiteColor];
    } else {
        return self.foregroundColor;
    }
}

- (UIColor*)backgroundColorForStyle {
    if(self.defaultStyle == SVProgressHUDStyleLight) {
        return [UIColor whiteColor];
    } else if(self.defaultStyle == SVProgressHUDStyleDark) {
        return [UIColor blackColor];
    } else {
        return self.backgroundColor;
    }
}

- (UIImage*)image:(UIImage*)image withTintColor:(UIColor*)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, image.size.width, image.size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, image.scale);
    CGContextRef c = UIGraphicsGetCurrentContext();
    [image drawInRect:rect];
    CGContextSetFillColorWithColor(c, [color CGColor]);
    CGContextSetBlendMode(c, kCGBlendModeSourceAtop);
    CGContextFillRect(c, rect);
    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return tintedImage;
}

- (BOOL)isClear { // used for iOS 7 and above
    return (self.defaultMaskType == SVProgressHUDMaskTypeClear || self.defaultMaskType == SVProgressHUDMaskTypeNone);
}

- (UIControl*)overlayView {
    if(!_overlayView) {
        _overlayView = [[UIControl alloc] init];
        _overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _overlayView.backgroundColor = [UIColor clearColor];
        [_overlayView addTarget:self action:@selector(overlayViewDidReceiveTouchEvent:forEvent:) forControlEvents:UIControlEventTouchDown];
    }
    // Update frame
#if !defined(SV_APP_EXTENSIONS)
    CGRect windowBounds = [[[UIApplication sharedApplication] delegate] window].bounds;
    _overlayView.frame = windowBounds;
#else
    _overlayView.frame = [UIScreen mainScreen].bounds;
#endif
    
    return _overlayView;
}

- (UIView*)hudView {
    if(!_hudView) {
        _hudView = [[UIView alloc] initWithFrame:CGRectZero];
        _hudView.layer.masksToBounds = YES;
        _hudView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
    }
    
    // Update styling
    _hudView.layer.cornerRadius = self.cornerRadius;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    // On iOS 8, the background color is set via a UIVisualEffectsView, see updateBlurBounds:
    _hudView.backgroundColor = self.defaultStyle == SVProgressHUDStyleCustom ? self.backgroundColor : [UIColor clearColor];
#else
    _hudView.backgroundColor = self.backgroundColorForStyle;
#endif
    return _hudView;
}

- (UILabel*)statusLabel {
    if(!_statusLabel) {
        _statusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _statusLabel.backgroundColor = [UIColor clearColor];
        _statusLabel.adjustsFontSizeToFitWidth = YES;
        _statusLabel.textAlignment = NSTextAlignmentCenter;
        _statusLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        _statusLabel.numberOfLines = 0;
    }
    if(!_statusLabel.superview) {
        [self.hudView addSubview:_statusLabel];
    }
    
    // Update styling
    _statusLabel.textColor = self.foregroundColorForStyle;
    _statusLabel.font = self.font;

    return _statusLabel;
}

- (UIImageView*)imageView {
    if(!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 28.0f, 28.0f)];
    }
    if(!_imageView.superview) {
        [self.hudView addSubview:_imageView];
    }
    return _imageView;
}

- (CGFloat)visibleKeyboardHeight {
#if !defined(SV_APP_EXTENSIONS)
    UIWindow *keyboardWindow = nil;
    for (UIWindow *testWindow in [[UIApplication sharedApplication] windows]) {
        if(![[testWindow class] isEqual:[UIWindow class]]) {
            keyboardWindow = testWindow;
            break;
        }
    }
    
    for (__strong UIView *possibleKeyboard in [keyboardWindow subviews]) {
        if([possibleKeyboard isKindOfClass:NSClassFromString(@"UIPeripheralHostView")] || [possibleKeyboard isKindOfClass:NSClassFromString(@"UIKeyboard")]) {
            return CGRectGetHeight(possibleKeyboard.bounds);
        } else if([possibleKeyboard isKindOfClass:NSClassFromString(@"UIInputSetContainerView")]) {
            for (__strong UIView *possibleKeyboardSubview in [possibleKeyboard subviews]) {
                if([possibleKeyboardSubview isKindOfClass:NSClassFromString(@"UIInputSetHostView")]) {
                    return CGRectGetHeight(possibleKeyboardSubview.bounds);
                }
            }
        }
    }
#endif
    return 0;
}


#pragma mark - UIAppearance Setters

- (void)setDefaultStyle:(SVProgressHUDStyle)style {
    if (!_isInitializing) _defaultStyle = style;
}

- (void)setDefaultMaskType:(SVProgressHUDMaskType)maskType {
    if (!_isInitializing) _defaultMaskType = maskType;
}

- (void)setDefaultAnimationType:(SVProgressHUDAnimationType)animationType {
    if (!_isInitializing) _defaultAnimationType = animationType;
}

- (void)setMinimumSize:(CGSize)minimumSize {
    if (!_isInitializing) _minimumSize = minimumSize;
}

- (void)setRingThickness:(CGFloat)ringThickness {
    if (!_isInitializing) _ringThickness = ringThickness;
}

- (void)setRingRadius:(CGFloat)ringRadius {
    if (!_isInitializing) _ringRadius = ringRadius;
}

- (void)setRingNoTextRadius:(CGFloat)ringNoTextRadius {
    if (!_isInitializing) _ringNoTextRadius = ringNoTextRadius;
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    if (!_isInitializing) _cornerRadius = cornerRadius;
}

- (void)setFont:(UIFont*)font {
    if (!_isInitializing) _font = font;
}

- (void)setForegroundColor:(UIColor*)color {
    if (!_isInitializing) _foregroundColor = color;
}

- (void)setBackgroundColor:(UIColor*)color {
    if (!_isInitializing) _backgroundColor = color;
}

- (void)setBackgroundLayerColor:(UIColor*)color {
    if (!_isInitializing) _backgroundLayerColor = color;
}

- (void)setInfoImage:(UIImage*)image {
    if (!_isInitializing) _infoImage = image;
}

- (void)setSuccessImage:(UIImage*)image {
    if (!_isInitializing) _successImage = image;
}

- (void)setErrorImage:(UIImage*)image {
    if (!_isInitializing) _errorImage = image;
}

- (void)setViewForExtension:(UIView*)view {
    if (!_isInitializing) _viewForExtension = view;
}

- (void)setOffsetFromCenter:(UIOffset)offset {
    if (!_isInitializing) _offsetFromCenter = offset;
}

- (void)setMinimumDismissTimeInterval:(NSTimeInterval)minimumDismissTimeInterval {
    if (!_isInitializing) _minimumDismissTimeInterval = minimumDismissTimeInterval;
}

- (void)setFadeInAnimationDuration:(NSTimeInterval)duration {
    if (!_isInitializing) _fadeInAnimationDuration = duration;
}

- (void)setFadeOutAnimationDuration:(NSTimeInterval)duration  {
    if (!_isInitializing) _fadeOutAnimationDuration = duration;
}

- (void)setMaxSupportedWindowLevel:(UIWindowLevel)maxSupportedWindowLevel {
    if (!_isInitializing) _maxSupportedWindowLevel = maxSupportedWindowLevel;
}

@end

