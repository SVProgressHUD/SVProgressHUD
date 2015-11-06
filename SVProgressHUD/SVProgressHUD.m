//
//  SVProgressHUD.h
//  SVProgressHUD, https://github.com/TransitApp/SVProgressHUD
//
//  Copyright (c) 2011-2014 Sam Vermette and contributors. All rights reserved.
//

#if !__has_feature(objc_arc)
#error SVProgressHUD is ARC only. Either turn on ARC for the project or use -fobjc-arc flag
#endif

#import "SVProgressHUD.h"
#import "SVIndefiniteAnimatedView.h"
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

@interface SVProgressHUD ()

@property (nonatomic, strong, readonly) NSTimer *fadeOutTimer;
@property (nonatomic, readonly, getter = isClear) BOOL clear;

@property (nonatomic, strong) UIControl *overlayView;
@property (nonatomic, strong) UIView *hudView;

@property (nonatomic, strong) UILabel *stringLabel;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *indefiniteAnimatedView;
@property (nonatomic, strong) CALayer *backgroundLayer;

@property (nonatomic, readwrite) CGFloat progress;
@property (nonatomic, readwrite) NSUInteger activityCount;
@property (nonatomic, strong) CAShapeLayer *backgroundRingLayer;
@property (nonatomic, strong) CAShapeLayer *ringLayer;

@property (nonatomic, readonly) CGFloat visibleKeyboardHeight;

- (void)updateHUDFrame;
- (void)updateMask;
- (void)updateBlurBounds;
#if TARGET_OS_IOS
- (void)updateMotionEffectForOrientation:(UIInterfaceOrientation)orientation;
#endif
- (void)updateMotionEffectForXMotionEffectType:(UIInterpolatingMotionEffectType)xMotionEffectType yMotionEffectType:(UIInterpolatingMotionEffectType)yMotionEffectType;

- (void)setStatus:(NSString*)string;
- (void)setFadeOutTimer:(NSTimer*)newTimer;

- (void)registerNotifications;
- (NSDictionary*)notificationUserInfo;

- (void)positionHUD:(NSNotification*)notification;
- (void)moveToPoint:(CGPoint)newCenter rotateAngle:(CGFloat)angle;

- (void)overlayViewDidReceiveTouchEvent:(id)sender forEvent:(UIEvent*)event;

- (void)showProgress:(float)progress status:(NSString*)string;
- (void)showImage:(UIImage*)image status:(NSString*)status duration:(NSTimeInterval)duration;

- (void)dismissWithDelay:(NSTimeInterval)delay;
- (void)dismiss;

- (UIActivityIndicatorView *)createActivityIndicatorView;
- (SVIndefiniteAnimatedView *)createIndefiniteAnimatedView;
- (UIView *)indefiniteAnimatedView;
- (CAShapeLayer*)ringLayer;
- (CAShapeLayer*)backgroundRingLayer;
- (void)cancelRingLayerAnimation;
- (CAShapeLayer*)createRingLayerWithCenter:(CGPoint)center radius:(CGFloat)radius;

- (UIColor*)foregroundColorForStyle;
- (UIColor*)backgroundColorForStyle;
- (UIImage*)image:(UIImage*)image withTintColor:(UIColor*)color;

@end


@implementation SVProgressHUD {
    BOOL _isInitializing;
}

+ (SVProgressHUD*)sharedView{
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

+ (void)setStatus:(NSString*)status{
    [[self sharedView] setStatus:status];
}

+ (void)setDefaultStyle:(SVProgressHUDStyle)style{
    [self sharedView].defaultStyle = style;
}

+ (void)setDefaultMaskType:(SVProgressHUDMaskType)maskType{
    [self sharedView].defaultMaskType = maskType;
}

+ (void)setDefaultAnimationType:(SVProgressHUDAnimationType)type {
    [self sharedView].defaultAnimationType = type;
    // Reset indefiniteAnimatedView so it gets recreated with the new style
    [self sharedView].indefiniteAnimatedView = nil;
}

+ (void)setMinimumSize:(CGSize)minimumSize{
    [self sharedView].minimumSize = minimumSize;
}

+ (void)setRingThickness:(CGFloat)ringThickness{
    [self sharedView].ringThickness = ringThickness;
}

+ (void)setRingRadius:(CGFloat)radius{
    [self sharedView].ringRadius = radius;
}

+ (void)setRingNoTextRadius:(CGFloat)radius{
    [self sharedView].ringNoTextRadius = radius;
}

+ (void)setCornerRadius:(CGFloat)cornerRadius{
    [self sharedView].cornerRadius = cornerRadius;
}

+ (void)setFont:(UIFont*)font{
    [self sharedView].font = font;
}

+ (void)setForegroundColor:(UIColor*)color{
    [self sharedView].foregroundColor = color;
}

+ (void)setBackgroundColor:(UIColor*)color{
    [self sharedView].backgroundColor = color;
}

+ (void)setInfoImage:(UIImage*)image{
    [self sharedView].infoImage = image;
}

+ (void)setSuccessImage:(UIImage *)image {
    [self sharedView].successImage = image;
}

+ (void)setErrorImage:(UIImage *)image {
    [self sharedView].errorImage = image;
}

+ (void)setViewForExtension:(UIView *)view{
    [self sharedView].viewForExtension = view;
}

+ (void)setMinimumDismissTimeInterval:(NSTimeInterval)interval {
    [self sharedView].minimumDismissTimeInterval = interval;
}


#pragma mark - Show Methods

+ (void)show{
    [self showWithStatus:nil];
}

+ (void)showWithMaskType:(SVProgressHUDMaskType)maskType{
    SVProgressHUDMaskType existingMaskType = [self sharedView].defaultMaskType;
    [self setDefaultMaskType:maskType];
    [self show];
    [self setDefaultMaskType:existingMaskType];
}

+ (void)showWithStatus:(NSString*)status{
    [self sharedView];
    [self showProgress:SVProgressHUDUndefinedProgress status:status];
}

+ (void)showWithStatus:(NSString*)status maskType:(SVProgressHUDMaskType)maskType{
    SVProgressHUDMaskType existingMaskType = [self sharedView].defaultMaskType;
    [self setDefaultMaskType:maskType];
    [self showWithStatus:status];
    [self setDefaultMaskType:existingMaskType];
}

+ (void)showProgress:(float)progress{
    [self showProgress:progress status:nil];
}

+ (void)showProgress:(float)progress maskType:(SVProgressHUDMaskType)maskType{
    SVProgressHUDMaskType existingMaskType = [self sharedView].defaultMaskType;
    [self setDefaultMaskType:maskType];
    [self showProgress:progress];
    [self setDefaultMaskType:existingMaskType];
}

+ (void)showProgress:(float)progress status:(NSString*)status{
    [[self sharedView] showProgress:progress status:status];
}

+ (void)showProgress:(float)progress status:(NSString*)status maskType:(SVProgressHUDMaskType)maskType{
    SVProgressHUDMaskType existingMaskType = [self sharedView].defaultMaskType;
    [self setDefaultMaskType:maskType];
    [self showProgress:progress status:status];
    [self setDefaultMaskType:existingMaskType];
}

#pragma mark - Show, then automatically dismiss methods

+ (void)showInfoWithStatus:(NSString*)status{
    [self showImage:[self sharedView].infoImage status:status];
}

+ (void)showInfoWithStatus:(NSString*)status maskType:(SVProgressHUDMaskType)maskType{
    SVProgressHUDMaskType existingMaskType = [self sharedView].defaultMaskType;
    [self setDefaultMaskType:maskType];
    [self showInfoWithStatus:status];
    [self setDefaultMaskType:existingMaskType];
}

+ (void)showSuccessWithStatus:(NSString*)status{
    [self showImage:[self sharedView].successImage status:status];
}

+ (void)showSuccessWithStatus:(NSString*)status maskType:(SVProgressHUDMaskType)maskType{
    SVProgressHUDMaskType existingMaskType = [self sharedView].defaultMaskType;
    [self setDefaultMaskType:maskType];
    [self showSuccessWithStatus:status];
    [self setDefaultMaskType:existingMaskType];
}

+ (void)showErrorWithStatus:(NSString*)status{
    [self showImage:[self sharedView].errorImage status:status];
}

+ (void)showErrorWithStatus:(NSString*)status maskType:(SVProgressHUDMaskType)maskType{
    SVProgressHUDMaskType existingMaskType = [self sharedView].defaultMaskType;
    [self setDefaultMaskType:maskType];
    [self showErrorWithStatus:status];
    [self setDefaultMaskType:existingMaskType];
}

+ (void)showImage:(UIImage*)image status:(NSString*)status{
    NSTimeInterval displayInterval = [self displayDurationForString:status];
    [[self sharedView] showImage:image status:status duration:displayInterval];
}

+ (void)showImage:(UIImage*)image status:(NSString*)status maskType:(SVProgressHUDMaskType)maskType{
    SVProgressHUDMaskType existingMaskType = [self sharedView].defaultMaskType;
    [self setDefaultMaskType:maskType];
    [self showImage:image status:status];
    [self setDefaultMaskType:existingMaskType];
}


#pragma mark - Dismiss Methods

+ (void)popActivity{
    if([self sharedView].activityCount > 0){
        [self sharedView].activityCount--;
    }
    if([self sharedView].activityCount == 0){
        [[self sharedView] dismiss];
    }
}

+ (void)dismissWithDelay:(NSTimeInterval)delay{
    if([self isVisible]){
        [[self sharedView] dismissWithDelay:delay];
    }
}

+ (void)dismiss{
    [self dismissWithDelay:0];
}


#pragma mark - Offset

+ (void)setOffsetFromCenter:(UIOffset)offset{
    [self sharedView].offsetFromCenter = offset;
}

+ (void)resetOffsetFromCenter{
    [self setOffsetFromCenter:UIOffsetZero];
}


#pragma mark - Instance Methods

- (instancetype)initWithFrame:(CGRect)frame{
    if((self = [super initWithFrame:frame])){
        _isInitializing = YES;
        
        self.userInteractionEnabled = NO;
        _backgroundColor = [UIColor clearColor];
        _foregroundColor = [UIColor blackColor];
        self.alpha = 0.0f;
        self.activityCount = 0;
        
        _defaultMaskType = SVProgressHUDMaskTypeNone;
        _defaultStyle = SVProgressHUDStyleLight;
        _defaultAnimationType = SVProgressHUDAnimationTypeFlat;

        // add accessibility support
        self.accessibilityIdentifier = @"SVProgressHUD";
        self.accessibilityLabel = @"SVProgressHUD";
        self.isAccessibilityElement = YES;
        
        if ([UIFont respondsToSelector:@selector(preferredFontForTextStyle:)]) {
            _font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        } else {
            _font = [UIFont systemFontOfSize:14.0f];
        }
        
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
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

        _ringThickness = 2;
        _ringRadius = 18;
        _ringNoTextRadius = 24;
        
        _cornerRadius = 14;
        
        _minimumDismissTimeInterval = 5.0f;
        
        _isInitializing = NO;
    }
    return self;
}

- (void)updateHUDFrame{
    CGFloat hudWidth = 100.0f;
    CGFloat hudHeight = 100.0f;
    CGFloat stringHeightBuffer = 20.0f;
    CGFloat stringAndContentHeightBuffer = 80.0f;
    CGRect labelRect = CGRectZero;
    
    // Check if an image or progress ring is displayed
    BOOL imageUsed = (self.imageView.image) || (self.imageView.hidden);
    BOOL progressUsed = (self.progress != SVProgressHUDUndefinedProgress) && (self.progress >= 0.0f);
    
    // Calculate and apply sizes
    NSString *string = self.stringLabel.text;
    if(string){
        CGSize constraintSize = CGSizeMake(200.0f, 300.0f);
        CGRect stringRect;
        if([string respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]){
            stringRect = [string boundingRectWithSize:constraintSize
                                              options:(NSStringDrawingOptions)(NSStringDrawingUsesFontLeading|NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin)
                                           attributes:@{NSFontAttributeName: self.stringLabel.font}
                                              context:NULL];
        } else{
            CGSize stringSize;
            if([string respondsToSelector:@selector(sizeWithAttributes:)]){
                stringSize = [string sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:self.stringLabel.font.fontName size:self.stringLabel.font.pointSize]}];
            } else{
#if TARGET_OS_IOS
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
                stringSize = [string sizeWithFont:self.stringLabel.font constrainedToSize:CGSizeMake(200.0f, 300.0f)];
#pragma clang diagnostic pop
#endif
            }
            stringRect = CGRectMake(0.0f, 0.0f, stringSize.width, stringSize.height);
        }

        CGFloat stringWidth = stringRect.size.width;
        CGFloat stringHeight = ceilf(CGRectGetHeight(stringRect));
        
        if(imageUsed || progressUsed){
            hudHeight = stringAndContentHeightBuffer + stringHeight;
        } else{
            hudHeight = stringHeightBuffer + stringHeight;
        }
        if(stringWidth > hudWidth){
            hudWidth = ceilf(stringWidth/2)*2;
        }
        CGFloat labelRectY = (imageUsed || progressUsed) ? 68.0f : 9.0f;
        if(hudHeight > 100.0f){
            labelRect = CGRectMake(12.0f, labelRectY, hudWidth, stringHeight);
            hudWidth += 24.0f;
        } else{
            hudWidth += 24.0f;
            labelRect = CGRectMake(0.0f, labelRectY, hudWidth, stringHeight);
        }
    }
    
    // Update values on subviews
    self.hudView.bounds = CGRectMake(0.0f, 0.0f, MAX(self.minimumSize.width, hudWidth), MAX(self.minimumSize.height, hudHeight));
    labelRect.size.width += MAX(0, self.minimumSize.width - hudWidth);
    [self updateBlurBounds];
    
    if(string){
        self.imageView.center = CGPointMake(CGRectGetWidth(self.hudView.bounds)/2, 36.0f);
    } else{
       	self.imageView.center = CGPointMake(CGRectGetWidth(self.hudView.bounds)/2, CGRectGetHeight(self.hudView.bounds)/2);
    }

	self.stringLabel.hidden = NO;
	self.stringLabel.frame = labelRect;
    
    // Animate value update
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    
	if(string) {
        if(self.defaultAnimationType == SVProgressHUDAnimationTypeFlat) {
            SVIndefiniteAnimatedView *indefiniteAnimationView = (SVIndefiniteAnimatedView *)self.indefiniteAnimatedView;
            indefiniteAnimationView.radius = self.ringRadius;
            [indefiniteAnimationView sizeToFit];
        }
        
        CGPoint center = CGPointMake((CGRectGetWidth(self.hudView.bounds)/2), 36.0f);
        self.indefiniteAnimatedView.center = center;
        
        if(self.progress != SVProgressHUDUndefinedProgress){
            self.backgroundRingLayer.position = self.ringLayer.position = CGPointMake((CGRectGetWidth(self.hudView.bounds)/2), 36.0f);
        }
	} else {
        if(self.defaultAnimationType == SVProgressHUDAnimationTypeFlat) {
            SVIndefiniteAnimatedView *indefiniteAnimationView = (SVIndefiniteAnimatedView *)self.indefiniteAnimatedView;
            indefiniteAnimationView.radius = self.ringNoTextRadius;
            [indefiniteAnimationView sizeToFit];
        }
        
        CGPoint center = CGPointMake((CGRectGetWidth(self.hudView.bounds)/2), CGRectGetHeight(self.hudView.bounds)/2);
        self.indefiniteAnimatedView.center = center;
        
        if(self.progress != SVProgressHUDUndefinedProgress){
            self.backgroundRingLayer.position = self.ringLayer.position = CGPointMake((CGRectGetWidth(self.hudView.bounds)/2), CGRectGetHeight(self.hudView.bounds)/2);
        }
    }
    
    [CATransaction commit];
}

- (void)updateMask{
    if(self.backgroundLayer){
        [self.backgroundLayer removeFromSuperlayer];
        self.backgroundLayer = nil;
    }
    switch (self.defaultMaskType){
        case SVProgressHUDMaskTypeBlack:{
            
            self.backgroundLayer = [CALayer layer];
            self.backgroundLayer.frame = self.bounds;
            self.backgroundLayer.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5].CGColor;
            [self.backgroundLayer setNeedsDisplay];
            
            [self.layer insertSublayer:self.backgroundLayer atIndex:0];
            break;
        }
            
        case SVProgressHUDMaskTypeGradient:{
            SVRadialGradientLayer *layer = [SVRadialGradientLayer layer];
            self.backgroundLayer = layer;
            self.backgroundLayer.frame = self.bounds;
            CGPoint gradientCenter = self.center;
            gradientCenter.y = (self.bounds.size.height - self.visibleKeyboardHeight) / 2;
            layer.gradientCenter = gradientCenter;
            [self.backgroundLayer setNeedsDisplay];
            
            [self.layer insertSublayer:self.backgroundLayer atIndex:0];
            break;
        }
        default:
            break;
    }
}

- (void)updateBlurBounds{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    if(NSClassFromString(@"UIBlurEffect")){
        // Remove background color, else the effect would not work
        self.hudView.backgroundColor = [UIColor clearColor];
        
        // Remove any old instances of UIVisualEffectViews
        for (UIView *subview in self.hudView.subviews){
            if([subview isKindOfClass:[UIVisualEffectView class]]){
                [subview removeFromSuperview];
            }
        }
        
        if(self.backgroundColor != [UIColor clearColor]){
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
    }
#endif
}

#if TARGET_OS_IOS
- (void)updateMotionEffectForOrientation:(UIInterfaceOrientation)orientation{
    UIInterpolatingMotionEffectType xMotionEffectType = UIInterfaceOrientationIsPortrait(orientation) ? UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis : UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis;
    UIInterpolatingMotionEffectType yMotionEffectType = UIInterfaceOrientationIsPortrait(orientation) ? UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis : UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis;
    [self updateMotionEffectForXMotionEffectType:xMotionEffectType yMotionEffectType:yMotionEffectType];
}
#endif

- (void)updateMotionEffectForXMotionEffectType:(UIInterpolatingMotionEffectType)xMotionEffectType yMotionEffectType:(UIInterpolatingMotionEffectType)yMotionEffectType{
    if([_hudView respondsToSelector:@selector(addMotionEffect:)]){
        UIInterpolatingMotionEffect *effectX = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:xMotionEffectType];
        effectX.minimumRelativeValue = @(-SVProgressHUDParallaxDepthPoints);
        effectX.maximumRelativeValue = @(SVProgressHUDParallaxDepthPoints);
        
        UIInterpolatingMotionEffect *effectY = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:yMotionEffectType];
        effectY.minimumRelativeValue = @(-SVProgressHUDParallaxDepthPoints);
        effectY.maximumRelativeValue = @(SVProgressHUDParallaxDepthPoints);
        
        UIMotionEffectGroup *effectGroup = [[UIMotionEffectGroup alloc] init];
        effectGroup.motionEffects = @[effectX, effectY];
        
        // Update motion effects
        self.hudView.motionEffects = @[];
        [self.hudView addMotionEffect:effectGroup];
    }
}

- (void)setStatus:(NSString*)string{
    self.stringLabel.text = string;
    [self updateHUDFrame];
}

- (void)setFadeOutTimer:(NSTimer*)newTimer{
    if(_fadeOutTimer){
        [_fadeOutTimer invalidate], _fadeOutTimer = nil;
    }
    if(newTimer){
        _fadeOutTimer = newTimer;
    }
}


#pragma mark - Notifications and their handling

- (void)registerNotifications{
#ifndef TARGET_OS_IOS
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(positionHUD:)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
#endif
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(positionHUD:)
                                                 name:UIApplicationDidBecomeActiveNotification
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
}

- (NSDictionary*)notificationUserInfo{
    return (self.stringLabel.text ? @{SVProgressHUDStatusUserInfoKey : self.stringLabel.text} : nil);
}

- (void)positionHUD:(NSNotification*)notification{
    CGFloat keyboardHeight = 0.0f;
    double animationDuration = 0.0;

#if !defined(SV_APP_EXTENSIONS) && TARGET_OS_IOS
    self.frame = [[[UIApplication sharedApplication] delegate] window].bounds;
    UIInterfaceOrientation orientation = UIApplication.sharedApplication.statusBarOrientation;
#elif !defined(SV_APP_EXTENSIONS)
    self.frame = [UIApplication sharedApplication].keyWindow.bounds;
#else
    if (self.viewForExtension){
        self.frame = self.viewForExtension.frame;
    } else {
        self.frame = UIScreen.mainScreen.bounds;
    }
    UIInterfaceOrientation orientation = CGRectGetWidth(self.frame) > CGRectGetHeight(self.frame) ? UIInterfaceOrientationLandscapeLeft : UIInterfaceOrientationPortrait;
#endif
    
    // no transforms applied to window in iOS 8, but only if compiled with iOS 8 sdk as base sdk, otherwise system supports old rotation logic.
    BOOL ignoreOrientation = NO;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    if([[NSProcessInfo processInfo] respondsToSelector:@selector(operatingSystemVersion)]){
        ignoreOrientation = YES;
    }
#endif
    
    // Get keyboardHeight in regards to current state
    if(notification){
        NSDictionary* keyboardInfo = [notification userInfo];
        CGRect keyboardFrame = [keyboardInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
        animationDuration = [keyboardInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        
        if(notification.name == UIKeyboardWillShowNotification || notification.name == UIKeyboardDidShowNotification){
            keyboardHeight = CGRectGetWidth(keyboardFrame);
#if TARGET_OS_IOS
            if(ignoreOrientation || UIInterfaceOrientationIsPortrait(orientation)){
                keyboardHeight = CGRectGetHeight(keyboardFrame);
            }
#endif
        }
    } else{
        keyboardHeight = self.visibleKeyboardHeight;
    }
    
    // Get the currently active frame of the display (depends on orientation)
    CGRect orientationFrame = self.bounds;

#if !defined(SV_APP_EXTENSIONS) && TARGET_OS_IOS
    CGRect statusBarFrame = UIApplication.sharedApplication.statusBarFrame;
#else
    CGRect statusBarFrame = CGRectZero;
#endif
    
#if TARGET_OS_IOS
    if(!ignoreOrientation && UIInterfaceOrientationIsLandscape(orientation)){
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
    if(keyboardHeight > 0){
        activeHeight += CGRectGetHeight(statusBarFrame)*2;
    }
    activeHeight -= keyboardHeight;
    
    CGFloat posX = CGRectGetWidth(orientationFrame)/2.0f;
    CGFloat posY = floorf(activeHeight*0.45f);

    CGFloat rotateAngle = 0.0;
    CGPoint newCenter = CGPointMake(posX, posY);
    
    // Update posX and posY in regards to orientation
#if TARGET_OS_IOS
    if(!ignoreOrientation){
        switch (orientation){
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
    
    if(notification){
        // Animate update if notification was present
        [UIView animateWithDuration:animationDuration
                              delay:0
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             [self moveToPoint:newCenter rotateAngle:rotateAngle];
                             [self.hudView setNeedsDisplay];
                         } completion:NULL];
    } else{
        [self moveToPoint:newCenter rotateAngle:rotateAngle];
        [self.hudView setNeedsDisplay];
    }
    
    [self updateMask];
}

- (void)moveToPoint:(CGPoint)newCenter rotateAngle:(CGFloat)angle{
    self.hudView.transform = CGAffineTransformMakeRotation(angle);
    self.hudView.center = CGPointMake(newCenter.x + self.offsetFromCenter.horizontal, newCenter.y + self.offsetFromCenter.vertical);
}


#pragma mark - Event handling

- (void)overlayViewDidReceiveTouchEvent:(id)sender forEvent:(UIEvent*)event{
    [[NSNotificationCenter defaultCenter] postNotificationName:SVProgressHUDDidReceiveTouchEventNotification object:event];
    
    UITouch *touch = event.allTouches.anyObject;
    CGPoint touchLocation = [touch locationInView:self];
    
    if(CGRectContainsPoint(self.hudView.frame, touchLocation)){
        [[NSNotificationCenter defaultCenter] postNotificationName:SVProgressHUDDidTouchDownInsideNotification object:event];
    }
}


#pragma mark - Master show/dismiss methods

- (void)showProgress:(float)progress status:(NSString*)string{
    if(!self.overlayView.superview){
#if !defined(SV_APP_EXTENSIONS)
        NSEnumerator *frontToBackWindows = [UIApplication.sharedApplication.windows reverseObjectEnumerator];
        for (UIWindow *window in frontToBackWindows){
            BOOL windowOnMainScreen = window.screen == UIScreen.mainScreen;
            BOOL windowIsVisible = !window.hidden && window.alpha > 0;
            BOOL windowLevelNormal = window.windowLevel == UIWindowLevelNormal;
            
            if(windowOnMainScreen && windowIsVisible && windowLevelNormal){
                [window addSubview:self.overlayView];
                break;
            }
        }
#else
        if(self.viewForExtension){
            [self.viewForExtension addSubview:self.overlayView];
        }
#endif
    } else{
        // Ensure that overlay will be exactly on top of rootViewController (which may be changed during runtime).
        [self.overlayView.superview bringSubviewToFront:self.overlayView];
    }
    
    if(!self.superview){
        [self.overlayView addSubview:self];
    }
    
    if(self.fadeOutTimer){
        self.activityCount = 0;
    }
    self.fadeOutTimer = nil;
    self.imageView.hidden = YES;
    self.progress = progress;
    
    self.stringLabel.text = string;
    [self updateHUDFrame];
    
    if(progress >= 0){
        self.imageView.image = nil;
        self.imageView.hidden = NO;
        
        [self.indefiniteAnimatedView removeFromSuperview];
        if([self.indefiniteAnimatedView respondsToSelector:@selector(stopAnimating)]) {
            [(id)self.indefiniteAnimatedView stopAnimating];
        }
        
        self.ringLayer.strokeEnd = progress;
        
        if(progress == 0){
            self.activityCount++;
        }
    } else{
        self.activityCount++;
        [self cancelRingLayerAnimation];
        
        [self.hudView addSubview:self.indefiniteAnimatedView];
        if([self.indefiniteAnimatedView respondsToSelector:@selector(startAnimating)]) {
            [(id)self.indefiniteAnimatedView startAnimating];
        }
    }
    
    if(self.defaultMaskType != SVProgressHUDMaskTypeNone){
        self.overlayView.userInteractionEnabled = YES;
        self.accessibilityLabel = string;
        self.isAccessibilityElement = YES;
    } else{
        self.overlayView.userInteractionEnabled = NO;
        self.hudView.accessibilityLabel = string;
        self.hudView.isAccessibilityElement = YES;
    }
    
    self.overlayView.hidden = NO;
    self.overlayView.backgroundColor = [UIColor clearColor];
    [self positionHUD:nil];
    
    // Appear
    if(self.alpha != 1 || self.hudView.alpha != 1){
        NSDictionary *userInfo = [self notificationUserInfo];
        [[NSNotificationCenter defaultCenter] postNotificationName:SVProgressHUDWillAppearNotification
                                                            object:nil
                                                          userInfo:userInfo];
        
        [self registerNotifications];
        self.hudView.transform = CGAffineTransformScale(self.hudView.transform, 1.3, 1.3);
        
        if(self.isClear){
            self.alpha = 1;
            self.hudView.alpha = 0;
        }
        
        __weak SVProgressHUD *weakSelf = self;
        [UIView animateWithDuration:0.15
                              delay:0
                            options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             __strong SVProgressHUD *strongSelf = weakSelf;
                             if(strongSelf){
                                 strongSelf.hudView.transform = CGAffineTransformScale(strongSelf.hudView.transform, 1/1.3f, 1/1.3f);
                                 
                                 if(strongSelf.isClear){ // handle iOS 7 and 8 UIToolbar which not answers well to hierarchy opacity change
                                     strongSelf.hudView.alpha = 1;
                                 } else{
                                     strongSelf.alpha = 1;
                                 }
                             }
                         }
                         completion:^(BOOL finished){
                             [[NSNotificationCenter defaultCenter] postNotificationName:SVProgressHUDDidAppearNotification
                                                                                 object:nil
                                                                               userInfo:userInfo];
                             UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
                             UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, string);
                         }];
        
        [self setNeedsDisplay];
    }
}

- (void)showImage:(UIImage*)image status:(NSString*)string duration:(NSTimeInterval)duration{
    self.progress = SVProgressHUDUndefinedProgress;
    [self cancelRingLayerAnimation];
    
    if(![self.class isVisible]){
        [self.class show];
    }
    
    UIColor *tintColor = self.foregroundColorForStyle;
    if([self.imageView respondsToSelector:@selector(setTintColor:)]){
        if (image.renderingMode != UIImageRenderingModeAlwaysTemplate) {
            image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }
        self.imageView.tintColor = tintColor;
    } else{
        image = [self image:image withTintColor:tintColor];
    }
    self.imageView.image = image;
    self.imageView.hidden = NO;
    
    self.stringLabel.text = string;
    [self updateHUDFrame];
    [self.indefiniteAnimatedView removeFromSuperview];
    if([self.indefiniteAnimatedView respondsToSelector:@selector(stopAnimating)]) {
        [(id)self.indefiniteAnimatedView stopAnimating];
    }
    
    if(self.defaultMaskType != SVProgressHUDMaskTypeNone){
        self.overlayView.userInteractionEnabled = YES;
        self.accessibilityLabel = string;
        self.isAccessibilityElement = YES;
    } else{
        self.overlayView.userInteractionEnabled = NO;
        self.hudView.accessibilityLabel = string;
        self.hudView.isAccessibilityElement = YES;
    }
    
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
    UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, string);
    
    self.fadeOutTimer = [NSTimer timerWithTimeInterval:duration target:self selector:@selector(dismiss) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:self.fadeOutTimer forMode:NSRunLoopCommonModes];
}

- (void)dismissWithDelay:(NSTimeInterval)delay{
    NSDictionary *userInfo = [self notificationUserInfo];
    [[NSNotificationCenter defaultCenter] postNotificationName:SVProgressHUDWillDisappearNotification
                                                        object:nil
                                                      userInfo:userInfo];
    
    self.activityCount = 0;
    __weak SVProgressHUD *weakSelf = self;
    [UIView animateWithDuration:0.15
                          delay:delay
                        options:(UIViewAnimationOptions) (UIViewAnimationCurveEaseIn | UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         __strong SVProgressHUD *strongSelf = weakSelf;
                         if(strongSelf){
                             strongSelf.hudView.transform = CGAffineTransformScale(self.hudView.transform, 0.8f, 0.8f);
                             if(strongSelf.isClear){ // handle iOS 7 UIToolbar not answer well to hierarchy opacity change
                                 strongSelf.hudView.alpha = 0.0f;
                             } else{
                                 strongSelf.alpha = 0.0f;
                             }
                         }
                     }
                     completion:^(BOOL finished){
                         __strong SVProgressHUD *strongSelf = weakSelf;
                         if(strongSelf){
                             if(strongSelf.alpha == 0.0f || strongSelf.hudView.alpha == 0.0f){
                                 strongSelf.alpha = 0.0f;
                                 strongSelf.hudView.alpha = 0.0f;
                                 
                                 [[NSNotificationCenter defaultCenter] removeObserver:strongSelf];
                                 [strongSelf cancelRingLayerAnimation];
                                 [_hudView removeFromSuperview];
                                 _hudView = nil;
                                 
                                 [_overlayView removeFromSuperview];
                                 _overlayView = nil;
                                 
                                 [_indefiniteAnimatedView removeFromSuperview];
                                 _indefiniteAnimatedView = nil;
                                 
                                 UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
                                 
                                 [[NSNotificationCenter defaultCenter] postNotificationName:SVProgressHUDDidDisappearNotification
                                                                                     object:nil
                                                                                   userInfo:userInfo];
                                 
                                 // Tell the rootViewController to update the StatusBar appearance
#if !defined(SV_APP_EXTENSIONS) && TARGET_OS_IOS
                                 UIViewController *rootController = [[UIApplication sharedApplication] keyWindow].rootViewController;
                                 if([rootController respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]){
                                     [rootController setNeedsStatusBarAppearanceUpdate];
                                 }
#endif
                                 // uncomment to make sure UIWindow is gone from app.windows
                                 //NSLog(@"%@", [UIApplication sharedApplication].windows);
                                 //NSLog(@"keyWindow = %@", [[[UIApplication sharedApplication] delegate] window]);
                             }
                         }
                     }];
}

- (void)dismiss
{
    [self dismissWithDelay:0];
}


#pragma mark - Ring progress animation

- (UIActivityIndicatorView *)createActivityIndicatorView{
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicatorView.color = self.foregroundColorForStyle;
    [activityIndicatorView sizeToFit];
    return activityIndicatorView;
}

- (SVIndefiniteAnimatedView *)createIndefiniteAnimatedView{
    SVIndefiniteAnimatedView *indefiniteAnimatedView = [[SVIndefiniteAnimatedView alloc] initWithFrame:CGRectZero];
    indefiniteAnimatedView.strokeColor = self.foregroundColorForStyle;
    indefiniteAnimatedView.radius = self.stringLabel.text ? self.ringRadius : self.ringNoTextRadius;
    indefiniteAnimatedView.strokeThickness = self.ringThickness;
    [indefiniteAnimatedView sizeToFit];
    return indefiniteAnimatedView;
}

- (UIView *)indefiniteAnimatedView{
    if(_indefiniteAnimatedView == nil){
        _indefiniteAnimatedView = (self.defaultAnimationType == SVProgressHUDAnimationTypeFlat) ? [self createIndefiniteAnimatedView] : [self createActivityIndicatorView];
    }
    
    return _indefiniteAnimatedView;
}

- (CAShapeLayer*)ringLayer{
    if(!_ringLayer){
        CGPoint center = CGPointMake(CGRectGetWidth(_hudView.frame)/2, CGRectGetHeight(_hudView.frame)/2);
        _ringLayer = [self createRingLayerWithCenter:center radius:self.ringRadius];
        [self.hudView.layer addSublayer:_ringLayer];
    }
    _ringLayer.strokeColor = self.foregroundColorForStyle.CGColor;
    _ringLayer.lineWidth = self.ringThickness;
    
    return _ringLayer;
}

- (CAShapeLayer*)backgroundRingLayer{
    if(!_backgroundRingLayer){
        CGPoint center = CGPointMake(CGRectGetWidth(_hudView.frame)/2, CGRectGetHeight(_hudView.frame)/2);
        _backgroundRingLayer = [self createRingLayerWithCenter:center radius:self.ringRadius];
        _backgroundRingLayer.strokeEnd = 1;
        [self.hudView.layer addSublayer:_backgroundRingLayer];
    }
    _backgroundRingLayer.strokeColor = [self.foregroundColorForStyle colorWithAlphaComponent:0.1f].CGColor;
    _backgroundRingLayer.lineWidth = self.ringThickness;
    
    return _backgroundRingLayer;
}

- (void)cancelRingLayerAnimation{
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [_hudView.layer removeAllAnimations];
    
    _ringLayer.strokeEnd = 0.0f;
    if(_ringLayer.superlayer){
        [_ringLayer removeFromSuperlayer];
    }
    _ringLayer = nil;
    
    if(_backgroundRingLayer.superlayer){
        [_backgroundRingLayer removeFromSuperlayer];
    }
    _backgroundRingLayer = nil;
    
    [CATransaction commit];
}

- (CAShapeLayer*)createRingLayerWithCenter:(CGPoint)center radius:(CGFloat)radius{
    UIBezierPath* smoothedPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(radius, radius) radius:radius startAngle:(CGFloat) -M_PI_2 endAngle:(CGFloat) (M_PI + M_PI_2) clockwise:YES];
    
    CAShapeLayer *slice = [CAShapeLayer layer];
    slice.contentsScale = [[UIScreen mainScreen] scale];
    slice.frame = CGRectMake(center.x-radius, center.y-radius, radius*2, radius*2);
    slice.fillColor = [UIColor clearColor].CGColor;
    slice.lineCap = kCALineCapRound;
    slice.lineJoin = kCALineJoinBevel;
    slice.path = smoothedPath.CGPath;
    
    return slice;
}


#pragma mark - Utilities

+ (BOOL)isVisible{
    return ([self sharedView].alpha == 1);
}


#pragma mark - Getters
+ (NSTimeInterval)displayDurationForString:(NSString*)string{
    return MIN((float)string.length * 0.06 + 0.5, [self sharedView].minimumDismissTimeInterval);
}

- (UIColor *)foregroundColorForStyle{
    if(self.defaultStyle == SVProgressHUDStyleLight){
        return [UIColor blackColor];
    } else if(self.defaultStyle == SVProgressHUDStyleDark){
        return [UIColor whiteColor];
    } else{
        return self.foregroundColor;
    }
}

- (UIColor *)backgroundColorForStyle{
    if(self.defaultStyle == SVProgressHUDStyleLight){
        return [UIColor whiteColor];
    } else if(self.defaultStyle == SVProgressHUDStyleDark){
        return [UIColor blackColor];
    } else{
        return self.backgroundColor;
    }
}

- (UIImage*)image:(UIImage*)image withTintColor:(UIColor*)color{
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

- (BOOL)isClear{ // used for iOS 7 and above
    return (self.defaultMaskType == SVProgressHUDMaskTypeClear || self.defaultMaskType == SVProgressHUDMaskTypeNone);
}

- (UIControl*)overlayView{
    if(!_overlayView){
#if !defined(SV_APP_EXTENSIONS)
        CGRect windowBounds = [[[UIApplication sharedApplication] delegate] window].bounds;
        _overlayView = [[UIControl alloc] initWithFrame:windowBounds];
#else
        _overlayView = [[UIControl alloc] initWithFrame:[UIScreen mainScreen].bounds];
#endif
        _overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _overlayView.backgroundColor = [UIColor clearColor];
        [_overlayView addTarget:self action:@selector(overlayViewDidReceiveTouchEvent:forEvent:) forControlEvents:UIControlEventTouchDown];
    }
    return _overlayView;
}

- (UIView*)hudView{
    if(!_hudView){
        _hudView = [[UIView alloc] initWithFrame:CGRectZero];
        _hudView.layer.cornerRadius = self.cornerRadius;
        _hudView.layer.masksToBounds = YES;
        _hudView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
    }
    _hudView.backgroundColor = self.backgroundColorForStyle;
    
    if(!_hudView.superview){
        [self addSubview:_hudView];
    }
    return _hudView;
}

- (UILabel*)stringLabel{
    if(!_stringLabel){
        _stringLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _stringLabel.backgroundColor = [UIColor clearColor];
        _stringLabel.adjustsFontSizeToFitWidth = YES;
        _stringLabel.textAlignment = NSTextAlignmentCenter;
        _stringLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        _stringLabel.numberOfLines = 0;
    }
    _stringLabel.textColor = self.foregroundColorForStyle;
    _stringLabel.font = self.font;
    
    if(!_stringLabel.superview){
        [self.hudView addSubview:_stringLabel];
    }
    return _stringLabel;
}

- (UIImageView*)imageView{
    if(!_imageView){
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 28.0f, 28.0f)];
    }
    if(!_imageView.superview){
        [self.hudView addSubview:_imageView];
    }
    return _imageView;
}

- (CGFloat)visibleKeyboardHeight{
#if !defined(SV_APP_EXTENSIONS)
    UIWindow *keyboardWindow = nil;
    for (UIWindow *testWindow in [[UIApplication sharedApplication] windows]){
        if(![[testWindow class] isEqual:[UIWindow class]]){
            keyboardWindow = testWindow;
            break;
        }
    }
    
    for (__strong UIView *possibleKeyboard in [keyboardWindow subviews]){
        if([possibleKeyboard isKindOfClass:NSClassFromString(@"UIPeripheralHostView")] || [possibleKeyboard isKindOfClass:NSClassFromString(@"UIKeyboard")]){
            return CGRectGetHeight(possibleKeyboard.bounds);
        } else if([possibleKeyboard isKindOfClass:NSClassFromString(@"UIInputSetContainerView")]){
            for (__strong UIView *possibleKeyboardSubview in [possibleKeyboard subviews]){
                if([possibleKeyboardSubview isKindOfClass:NSClassFromString(@"UIInputSetHostView")]){
                    return CGRectGetHeight(possibleKeyboardSubview.bounds);
                }
            }
        }
    }
#endif
    return 0;
}

#pragma mark - UIAppearance Setters

- (void)setDefaultStyle:(SVProgressHUDStyle)style{
    if (!_isInitializing) _defaultStyle = style;
}

- (void)setDefaultMaskType:(SVProgressHUDMaskType)maskType{
    if (!_isInitializing) _defaultMaskType = maskType;
}

- (void)setDefaultAnimationType:(SVProgressHUDAnimationType)animationType{
    if (!_isInitializing) _defaultAnimationType = animationType;
}

- (void)setMinimumSize:(CGSize)minimumSize{
    if (!_isInitializing) _minimumSize = minimumSize;
}

- (void)setRingThickness:(CGFloat)ringThickness{
    if (!_isInitializing) _ringThickness = ringThickness;
}

- (void)setRingRadius:(CGFloat)ringRadius{
    if (!_isInitializing) _ringRadius = ringRadius;
}

- (void)setRingNoTextRadius:(CGFloat)ringNoTextRadius{
    if (!_isInitializing) _ringNoTextRadius = ringNoTextRadius;
}

- (void)setCornerRadius:(CGFloat)cornerRadius{
    if (!_isInitializing) _cornerRadius = cornerRadius;
}

- (void)setFont:(UIFont *)font{
    if (!_isInitializing) _font = font;
}

- (void)setBackgroundColor:(UIColor *)color{
    if (!_isInitializing) _backgroundColor = color;
}

- (void)setForegroundColor:(UIColor *)color{
    if (!_isInitializing) _foregroundColor = color;
}

- (void)setInfoImage:(UIImage*)image{
    if (!_isInitializing) _infoImage = image;
}

- (void)setSuccessImage:(UIImage *)image{
    if (!_isInitializing) _successImage = image;
}

- (void)setErrorImage:(UIImage *)image{
    if (!_isInitializing) _errorImage = image;
}

- (void)setViewForExtension:(UIView *)view{
    if (!_isInitializing) _viewForExtension = view;
}

- (void)setOffsetFromCenter:(UIOffset)offset{
    if (!_isInitializing) _offsetFromCenter = offset;
}

- (void)setMinimumDismissTimeInterval:(NSTimeInterval)minimumDismissTimeInterval{
    if (!_isInitializing) _minimumDismissTimeInterval = minimumDismissTimeInterval;
}

@end

