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

static const CGFloat SVProgressHUDParallaxDepthPoints = 10.0f;
static const CGFloat SVProgressHUDUndefinedProgress = -1;
static const CGFloat SVProgressHUDDefaultAnimationDuration = 0.15f;
static const CGFloat SVProgressHUDVerticalSpacing = 12.0f;
static const CGFloat SVProgressHUDHorizontalSpacing = 12.0f;
static const CGFloat SVProgressHUDLabelSpacing = 8.0f;


@interface SVProgressHUD ()

@property (nonatomic, strong) NSTimer *fadeOutTimer;

@property (nonatomic, strong) UIControl *controlView;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) SVRadialGradientLayer *backgroundRadialGradientLayer;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
@property (nonatomic, strong) UIVisualEffectView *hudView;
@property (nonatomic, strong) UIVisualEffectView *hudVibrancyView;
#else
@property (nonatomic, strong) UIView *hudView;
#endif
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UIView *indefiniteAnimatedView;
@property (nonatomic, strong) SVProgressAnimatedView *ringView;
@property (nonatomic, strong) SVProgressAnimatedView *backgroundRingView;

@property (nonatomic, readwrite) CGFloat progress;
@property (nonatomic, readwrite) NSUInteger activityCount;

@property (nonatomic, readonly) CGFloat visibleKeyboardHeight;
@property (nonatomic, readonly) UIWindow *frontWindow;

- (void)updateHUDFrame;

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

- (void)controlViewDidReceiveTouchEvent:(id)sender forEvent:(UIEvent*)event;

- (void)showProgress:(float)progress status:(NSString*)status;
- (void)showImage:(UIImage*)image status:(NSString*)status duration:(NSTimeInterval)duration;
- (void)showStatus:(NSString*)status;

- (void)dismiss;
- (void)dismissWithDelay:(NSTimeInterval)delay completion:(SVProgressHUDDismissCompletion)completion;

- (void)cancelRingLayerAnimation;
- (void)cancelIndefiniteAnimatedViewAnimation;

- (UIColor*)foregroundColorForStyle;
- (UIColor*)backgroundColorForStyle;

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
    [self sharedView].hudView.alpha = style != SVProgressHUDStyleCustom ? 1.0f : 0.0f;
}

+ (void)setDefaultMaskType:(SVProgressHUDMaskType)maskType {
    [self sharedView].defaultMaskType = maskType;
}

+ (void)setDefaultAnimationType:(SVProgressHUDAnimationType)type {
    [self sharedView].defaultAnimationType = type;
}

+ (void)setContainerView:(UIView *)containerView {
    [self sharedView].containerView = containerView;
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
    [self setDefaultStyle:SVProgressHUDStyleCustom];
}

+ (void)setBackgroundColor:(UIColor*)color {
    [self sharedView].backgroundColor = color;
    [self setDefaultStyle:SVProgressHUDStyleCustom];
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

+ (void)setMaximumDismissTimeInterval:(NSTimeInterval)interval {
    [self sharedView].maximumDismissTimeInterval = interval;
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
        self.activityCount = 0;
        
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
        self.hudView.contentView.alpha = 0.0f;
#else
        self.hudView.alpha = 0.0f;
#endif
        self.backgroundView.alpha = 0.0f;
        
        _backgroundColor = [UIColor clearColor];
        _foregroundColor = [UIColor blackColor];
        _backgroundLayerColor = [UIColor colorWithWhite:0 alpha:0.4];
        
        // Set default values
        _defaultMaskType = SVProgressHUDMaskTypeNone;
        _defaultStyle = SVProgressHUDStyleLight;
        _defaultAnimationType = SVProgressHUDAnimationTypeFlat;
        _minimumSize = CGSizeZero;
        _font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        
        NSBundle *bundle = [NSBundle bundleForClass:[SVProgressHUD class]];
        NSURL *url = [bundle URLForResource:@"SVProgressHUD" withExtension:@"bundle"];
        NSBundle *imageBundle = [NSBundle bundleWithURL:url];
        
        UIImage* infoImage = [UIImage imageWithContentsOfFile:[imageBundle pathForResource:@"info" ofType:@"png"]];
        UIImage* successImage = [UIImage imageWithContentsOfFile:[imageBundle pathForResource:@"success" ofType:@"png"]];
        UIImage* errorImage = [UIImage imageWithContentsOfFile:[imageBundle pathForResource:@"error" ofType:@"png"]];

        _infoImage = [infoImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _successImage = [successImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _errorImage = [errorImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

        _ringThickness = 2.0f;
        _ringRadius = 18.0f;
        _ringNoTextRadius = 24.0f;
        
        _cornerRadius = 14.0f;
        
        _minimumDismissTimeInterval = 5.0;
        _maximumDismissTimeInterval = CGFLOAT_MAX;

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
    // Check if an image or progress ring is displayed
    BOOL imageUsed = (self.imageView.image) && !(self.imageView.hidden);
    BOOL progressUsed = self.imageView.hidden;
    
    // Calculate size of string
    CGRect labelRect = CGRectZero;
    CGFloat labelHeight = 0.0f;
    CGFloat labelWidth = 0.0f;
    
    if(self.statusLabel.text) {
        CGSize constraintSize = CGSizeMake(200.0f, 300.0f);
        labelRect = [self.statusLabel.text boundingRectWithSize:constraintSize
                                                        options:(NSStringDrawingOptions)(NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin)
                                                     attributes:@{NSFontAttributeName: self.statusLabel.font}
                                                        context:NULL];
        labelHeight = ceilf(CGRectGetHeight(labelRect));
        labelWidth = ceilf(CGRectGetWidth(labelRect));
    }
    
    // Calculate hud size based on content
    // For the beginning use default values, these
    // might get update if string is too large etc.
    CGFloat hudWidth;
    CGFloat hudHeight;
    
    CGFloat contentWidth = 0.0f;
    CGFloat contentHeight = 0.0f;
    
    if(imageUsed || progressUsed) {
        contentWidth = CGRectGetWidth(imageUsed ? self.imageView.frame : self.indefiniteAnimatedView.frame);
        contentHeight = CGRectGetHeight(imageUsed ? self.imageView.frame : self.indefiniteAnimatedView.frame);
    }
    
    // |-spacing-content-spacing-|
    hudWidth = SVProgressHUDHorizontalSpacing + MAX(labelWidth, contentWidth) + SVProgressHUDHorizontalSpacing;
    
    // |-spacing-content-(labelSpacing-label-)spacing-|
    hudHeight = SVProgressHUDVerticalSpacing + labelHeight + contentHeight + SVProgressHUDVerticalSpacing;
    if(self.statusLabel.text && (imageUsed || progressUsed)){
        // Add spacing if both content and label are used
        hudHeight += SVProgressHUDLabelSpacing;
    }
    
    // Update values on subviews
    self.hudView.bounds = CGRectMake(0.0f, 0.0f, MAX(self.minimumSize.width, hudWidth), MAX(self.minimumSize.height, hudHeight));
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    self.hudVibrancyView.bounds = self.hudView.bounds;
#endif
    
    // Animate value update
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    // Spinner and image view
    CGFloat centerY;
    if(self.statusLabel.text) {
        CGFloat yOffset = MAX(SVProgressHUDVerticalSpacing, (self.minimumSize.height - contentHeight - SVProgressHUDLabelSpacing - labelHeight) / 2.0f);
        centerY = yOffset + contentHeight / 2.0f;
    } else {
        centerY = CGRectGetMidY(self.hudView.bounds);
    }
    self.indefiniteAnimatedView.center = CGPointMake(CGRectGetMidX(self.hudView.bounds), centerY);
    if(self.progress != SVProgressHUDUndefinedProgress) {
        self.backgroundRingView.center = self.ringView.center = CGPointMake(CGRectGetMidX(self.hudView.bounds), centerY);
    }
    self.imageView.center = CGPointMake(CGRectGetMidX(self.hudView.bounds), centerY);

    // Label
    if(imageUsed || progressUsed) {
        centerY = CGRectGetMaxY(imageUsed ? self.imageView.frame : self.indefiniteAnimatedView.frame) + SVProgressHUDLabelSpacing + labelHeight / 2.0f;
    } else {
        centerY = CGRectGetMidY(self.hudView.bounds);
    }
    self.statusLabel.frame = labelRect;
    self.statusLabel.center = CGPointMake(CGRectGetMidX(self.hudView.bounds), centerY);
    self.statusLabel.hidden = !self.statusLabel.text;
    
    [CATransaction commit];
}

#if TARGET_OS_IOS
- (void)updateMotionEffectForOrientation:(UIInterfaceOrientation)orientation {
    UIInterpolatingMotionEffectType xMotionEffectType = UIInterfaceOrientationIsPortrait(orientation) ? UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis : UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis;
    UIInterpolatingMotionEffectType yMotionEffectType = UIInterfaceOrientationIsPortrait(orientation) ? UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis : UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis;
    [self updateMotionEffectForXMotionEffectType:xMotionEffectType yMotionEffectType:yMotionEffectType];
}
#endif

- (void)updateMotionEffectForXMotionEffectType:(UIInterpolatingMotionEffectType)xMotionEffectType yMotionEffectType:(UIInterpolatingMotionEffectType)yMotionEffectType {
    UIInterpolatingMotionEffect *effectX = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:xMotionEffectType];
    effectX.minimumRelativeValue = @(-SVProgressHUDParallaxDepthPoints);
    effectX.maximumRelativeValue = @(SVProgressHUDParallaxDepthPoints);
    
    UIInterpolatingMotionEffect *effectY = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:yMotionEffectType];
    effectY.minimumRelativeValue = @(-SVProgressHUDParallaxDepthPoints);
    effectY.maximumRelativeValue = @(SVProgressHUDParallaxDepthPoints);
    
    UIMotionEffectGroup *effectGroup = [UIMotionEffectGroup new];
    effectGroup.motionEffects = @[effectX, effectY];
    
    // Clear old motion effect, then add new motion effects
    self.hudView.motionEffects = @[];
    [self.hudView addMotionEffect:effectGroup];
}

- (void)updateViewHierarchy {
    // Add the overlay to the application window if necessary
    if(!self.controlView.superview) {
        if(self.containerView){
            [self.containerView addSubview:self.controlView];
        } else {
#if !defined(SV_APP_EXTENSIONS)
            [self.frontWindow addSubview:self.controlView];
#else
            // If SVProgressHUD ist used inside an app extension add it to the given view
            if(self.viewForExtension) {
                [self.viewForExtension addSubview:self.controlView];
            }
#endif
        }
    } else {
        // The HUD is already on screen, but maybot not in front. Therefore
        // ensure that overlay will be on top of rootViewController (which may
        // be changed during runtime).
        [self.controlView.superview bringSubviewToFront:self.controlView];
    }
    
    // Add self to the overlay view
    if(!self.superview) {
        [self.controlView addSubview:self];
    }
}

- (void)setStatus:(NSString*)status {
    self.statusLabel.text = status;
    [self updateHUDFrame];
}

- (void)setFadeOutTimer:(NSTimer*)timer {
    if(_fadeOutTimer) {
        [_fadeOutTimer invalidate];
        _fadeOutTimer = nil;
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

- (NSDictionary*)notificationUserInfo {
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
        activeHeight += CGRectGetHeight(statusBarFrame) * 2;
    }
    activeHeight -= keyboardHeight;
    
    CGFloat posX = CGRectGetMidX(orientationFrame);
    CGFloat posY = floorf(activeHeight*0.45f);

    CGFloat rotateAngle = 0.0;
    CGPoint newCenter = CGPointMake(posX, posY);
    
    if(notification) {
        // Animate update if notification was present
        [UIView animateWithDuration:animationDuration
                              delay:0
                            options:(UIViewAnimationOptions) (UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState)
                         animations:^{
                             [self moveToPoint:newCenter rotateAngle:rotateAngle];
                             [self.hudView setNeedsDisplay];
                         } completion:nil];
    } else {
        [self moveToPoint:newCenter rotateAngle:rotateAngle];
    }
}

- (void)moveToPoint:(CGPoint)newCenter rotateAngle:(CGFloat)angle {
    self.hudView.transform = CGAffineTransformMakeRotation(angle);
    if (self.containerView) {
        self.hudView.center = self.containerView.center;
    } else {
        self.hudView.center = CGPointMake(newCenter.x + self.offsetFromCenter.horizontal, newCenter.y + self.offsetFromCenter.vertical);
    }
}


#pragma mark - Event handling

- (void)controlViewDidReceiveTouchEvent:(id)sender forEvent:(UIEvent*)event {
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
                if(!strongSelf.ringView.superview){
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
                    [strongSelf.hudVibrancyView.contentView addSubview:strongSelf.ringView];
#else
                    [strongSelf.hudView addSubview:strongSelf.ringView];
#endif
                }
                if(!strongSelf.backgroundRingView.superview){
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
                    [strongSelf.hudVibrancyView.contentView addSubview:strongSelf.backgroundRingView];
#else
                    [strongSelf.hudView addSubview:strongSelf.backgroundRingView];
#endif
                }
                
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
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
                [strongSelf.hudVibrancyView.contentView addSubview:strongSelf.indefiniteAnimatedView];
#else
                [strongSelf.hudView  addSubview:strongSelf.indefiniteAnimatedView];
#endif
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
            if (image.renderingMode != UIImageRenderingModeAlwaysTemplate) {
                tintedImage = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            }
            strongSelf.imageView.tintColor = tintColor;
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
        self.controlView.userInteractionEnabled = YES;
        self.accessibilityLabel = status;
        self.isAccessibilityElement = YES;
    } else {
        self.controlView.userInteractionEnabled = NO;
        self.hudView.accessibilityLabel = status;
        self.hudView.isAccessibilityElement = YES;
    }
    
    // Show if not already visible
    // Checking one alpha value is sufficient as they are all the same
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    if(self.hudView.contentView.alpha != 1.0f){
#else
    if(self.hudView.alpha != 1.0f){
#endif
        // Post notification to inform user
        [[NSNotificationCenter defaultCenter] postNotificationName:SVProgressHUDWillAppearNotification
                                                            object:self
                                                          userInfo:[self notificationUserInfo]];
        
        // Zoom HUD a little to make a nice appear / pop up animation
        self.hudView.transform = CGAffineTransformScale(self.hudView.transform, 1.3, 1.3);
        
        // Define blocks
        __block void (^animationsBlock)(void) = ^{
            // Shrink HUD to finish pop up animation
            self.hudView.transform = CGAffineTransformScale(self.hudView.transform, 1/1.3f, 1/1.3f);
            
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
            if(self.defaultStyle != SVProgressHUDStyleCustom){
                // Fade in effect
                UIBlurEffectStyle blurEffectStyle = self.defaultStyle == SVProgressHUDStyleDark ? UIBlurEffectStyleDark : UIBlurEffectStyleExtraLight;
                UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:blurEffectStyle];
                
                self.hudView.effect = blurEffect;
                self.hudVibrancyView.effect = [UIVibrancyEffect effectForBlurEffect:blurEffect];
            } else {
                self.hudView.alpha = 1.0f;
            }
            
            // Update alpha
            self.hudView.contentView.alpha = 1.0f;
#else
            self.hudView.alpha = 1.0f;
#endif
            self.backgroundView.alpha = 1.0f;
        };
        
        __block void (^completionBlock)(void) = ^{
            // Check if we really achieved to show the HUD (<=> alpha values are applied)
            // and the change of these values has not been cancelled in between e.g. due to a dismissal
            // Checking one alpha value is sufficient as they are all the same
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
            if(self.hudView.contentView.alpha == 1.0f){
#else
            if(self.hudView.alpha == 1.0f){
#endif
                // Register observer <=> we now have to handle orientation changes etc.
                [self registerNotifications];
                
                // Post notification to inform user
                [[NSNotificationCenter defaultCenter] postNotificationName:SVProgressHUDDidAppearNotification
                                                                    object:self
                                                                  userInfo:[self notificationUserInfo]];
            }
            
            // Update accessibility
            UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
            UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, status);
        };
        
        if (self.fadeInAnimationDuration > 0) {
            // Animate appearance
            [UIView animateWithDuration:self.fadeInAnimationDuration
                                  delay:0
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
                // Shrink HUD a little to make a nice disappear animation
                strongSelf.hudView.transform = CGAffineTransformScale(strongSelf.hudView.transform, 1/1.3f, 1/1.3f);
                
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
                if(self.defaultStyle != SVProgressHUDStyleCustom){
                    // Fade out effect == remove, and update alpha
                    strongSelf.hudView.effect = nil;
                    strongSelf.hudVibrancyView.effect = nil;
                } else {
                    strongSelf.hudView.alpha = 0.0f;
                }

                strongSelf.hudView.contentView.alpha = 0.0f;
#else
                strongSelf.hudView.alpha = 0.0f;
#endif
                strongSelf.backgroundView.alpha = 0.0f;
            };
            
            __block void (^completionBlock)(void) = ^{
                // Check if we really achieved to dismiss the HUD (<=> alpha values are applied)
                // and the change of these values has not been cancelled in between e.g. due to a new show
                // Checking one alpha value is sufficient as they are all the same
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
                if(strongSelf.hudView.contentView.alpha == 0.0f){
#else
                if(strongSelf.hudView.alpha == 0.0f){
#endif
                    // Clean up view hierarchy (overlays)
                    [strongSelf.controlView removeFromSuperview];
                    [strongSelf.backgroundView removeFromSuperview];
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
                    [rootController setNeedsStatusBarAppearanceUpdate];
#endif
                    // Update accessibility
                    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
                    
                    // Run an (optional) completionHandler
                    if (completion) {
                        completion();
                    }
                }
            };
                
            // UIViewAnimationOptionBeginFromCurrentState AND a delay doesn't always work as expected
            // When UIViewAnimationOptionBeginFromCurrentState ist set, animateWithDuration: evaluates the current
            // values to check if an animation is necessary. The evaluation happens at function call time and not
            // after the delay => the animation is sometimes skipped. Therefore we delay using dispatch_after.
                
            dispatch_time_t dipatchTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC));
            dispatch_after(dipatchTime, dispatch_get_main_queue(), ^{
                if (strongSelf.fadeOutAnimationDuration > 0) {
                    // Animate appearance
                    [UIView animateWithDuration:strongSelf.fadeOutAnimationDuration
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
            });
            
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
    // Checking one alpha value is sufficient as they are all the same
    return ([self sharedView].hudView.contentView.alpha > 0.0f);
}


#pragma mark - Getters

+ (NSTimeInterval)displayDurationForString:(NSString*)string {
    CGFloat minimum = MAX((CGFloat)string.length * 0.06 + 0.5, [self sharedView].minimumDismissTimeInterval);
    return MIN(minimum, [self sharedView].maximumDismissTimeInterval);
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
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    // On iOS 8 and SVProgressHUDStyleLight / SVProgressHUDStyleDark the
    // the background color is set via a UIVisualEffectsView
    return self.defaultStyle == SVProgressHUDStyleCustom ? self.backgroundColor : [UIColor clearColor];
#else
    if(self.defaultStyle == SVProgressHUDStyleLight) {
        return [UIColor whiteColor];
    } else if(self.defaultStyle == SVProgressHUDStyleDark) {
        return [UIColor blackColor];
    } else {
        return self.backgroundColor;
    }
#endif
}

- (UIControl*)controlView {
    if(!_controlView) {
        _controlView = [UIControl new];
        _controlView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _controlView.backgroundColor = [UIColor clearColor];
        [_controlView addTarget:self action:@selector(controlViewDidReceiveTouchEvent:forEvent:) forControlEvents:UIControlEventTouchDown];
    }
    
    // Update frames
#if !defined(SV_APP_EXTENSIONS)
    CGRect windowBounds = [[[UIApplication sharedApplication] delegate] window].bounds;
    _controlView.frame = windowBounds;
#else
    _controlView.frame = [UIScreen mainScreen].bounds;
#endif
    
    return _controlView;
}

-(UIView *)backgroundView {
    if(!_backgroundView){
        _backgroundView = [UIView new];
    }
    if(!_backgroundView.superview){
        [self insertSubview:_backgroundView belowSubview:self.hudView];
    }
    
    // Update styling
    switch (self.defaultMaskType) {
        case SVProgressHUDMaskTypeCustom:
        case SVProgressHUDMaskTypeBlack:{
            if(_backgroundRadialGradientLayer && _backgroundRadialGradientLayer.superlayer){
                [_backgroundRadialGradientLayer removeFromSuperlayer];
            }
            _backgroundView.backgroundColor = self.defaultMaskType == SVProgressHUDMaskTypeCustom ? self.backgroundLayerColor : [UIColor colorWithWhite:0 alpha:0.4];
            break;
        }
        case SVProgressHUDMaskTypeGradient:{
            if(!_backgroundRadialGradientLayer){
                _backgroundRadialGradientLayer = [SVRadialGradientLayer layer];
            }
            if(!_backgroundRadialGradientLayer.superlayer){
                [_backgroundView.layer insertSublayer:_backgroundRadialGradientLayer atIndex:0];
            }
        }
        default:
            break;
    }
    
    // Update frame
    if(_backgroundView){
        _backgroundView.frame = self.bounds;
    }
    if(_backgroundRadialGradientLayer){
        _backgroundRadialGradientLayer.frame = self.bounds;
        
        // Calculate the new center of the gradient, it may change if keyboard is visible
        CGPoint gradientCenter = self.center;
        gradientCenter.y = (self.bounds.size.height - self.visibleKeyboardHeight)/2;
        _backgroundRadialGradientLayer.gradientCenter = gradientCenter;
    }
    
    return _backgroundView;
}
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
- (UIVisualEffectView*)hudView {
#else
- (UIView*)hudView {
#endif
    if(!_hudView) {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
        _hudView = [UIVisualEffectView new];
#else
        _hudView = [UIView new];
#endif
        _hudView.layer.masksToBounds = YES;
        _hudView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
    }
    if(!_hudView.superview) {
        [self addSubview:_hudView];
    }
    
    // Update styling
    _hudView.layer.cornerRadius = self.cornerRadius;
    _hudView.backgroundColor = self.backgroundColorForStyle;
    
    return _hudView;
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
- (UIVisualEffectView*)hudVibrancyView {
    if(!_hudVibrancyView){
        _hudVibrancyView = [UIVisualEffectView new];
        
        _hudView.layer.masksToBounds = YES;
        _hudVibrancyView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
    }
    if(!_hudVibrancyView.superview){
        [self.hudView.contentView addSubview:_hudVibrancyView];
    }
    
    return _hudVibrancyView;
}
#endif

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
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
      [self.hudVibrancyView.contentView addSubview:_statusLabel];
#else
      [self.hudView addSubview:_statusLabel];
#endif
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
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
        [self.hudVibrancyView.contentView addSubview:_imageView];
#else
        [self.hudView addSubview:_imageView];
#endif
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

- (UIWindow *)frontWindow {
#if !defined(SV_APP_EXTENSIONS)
    NSEnumerator *frontToBackWindows = [UIApplication.sharedApplication.windows reverseObjectEnumerator];
    for (UIWindow *window in frontToBackWindows) {
        BOOL windowOnMainScreen = window.screen == UIScreen.mainScreen;
        BOOL windowIsVisible = !window.hidden && window.alpha > 0;
        BOOL windowLevelSupported = (window.windowLevel >= UIWindowLevelNormal && window.windowLevel <= self.maxSupportedWindowLevel);
        
        if(windowOnMainScreen && windowIsVisible && windowLevelSupported) {
            return window;
        }
    }
#endif
    return nil;
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

- (void)setContainerView:(UIView *)containerView {
    if (!_isInitializing) _containerView = containerView;
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
