//
//  SVProgressHUD.m
//
//  Created by Sam Vermette on 27.03.11.
//  Copyright 2011 Sam Vermette. All rights reserved.
//
//  https://github.com/samvermette/SVProgressHUD
//

#if !__has_feature(objc_arc)
#error SVProgressHUD is ARC only. Either turn on ARC for the project or use -fobjc-arc flag
#endif

#import "SVProgressHUD.h"
#import <QuartzCore/QuartzCore.h>

NSString * const SVProgressHUDDidReceiveTouchEventNotification = @"SVProgressHUDDidReceiveTouchEventNotification";
NSString * const SVProgressHUDWillDisappearNotification = @"SVProgressHUDWillDisappearNotification";
NSString * const SVProgressHUDDidDisappearNotification = @"SVProgressHUDDidDisappearNotification";

NSString * const SVProgressHUDStatusUserInfoKey = @"SVProgressHUDStatusUserInfoKey";

CGFloat SVProgressHUDRingRadius = 14;
CGFloat SVProgressHUDRingThickness = 6;

@interface SVProgressHUD ()

@property (nonatomic, readwrite) SVProgressHUDMaskType maskType;
@property (nonatomic, strong, readonly) NSTimer *fadeOutTimer;

@property (nonatomic, strong, readonly) UIButton *overlayView;
@property (nonatomic, strong, readonly) UIView *hudView;
@property (nonatomic, strong, readonly) UILabel *stringLabel;
@property (nonatomic, strong, readonly) UIImageView *imageView;
@property (nonatomic, strong, readonly) UIActivityIndicatorView *spinnerView;

@property (nonatomic, readwrite) CGFloat progress;
@property (nonatomic, readwrite) NSUInteger activityCount;
@property (nonatomic, strong) CAShapeLayer *backgroundRingLayer;
@property (nonatomic, strong) CAShapeLayer *ringLayer;

@property (nonatomic, readonly) CGFloat visibleKeyboardHeight;

- (void)showProgress:(float)progress
              status:(NSString*)string
            maskType:(SVProgressHUDMaskType)hudMaskType;

- (void)showImage:(UIImage*)image
           status:(NSString*)status
         duration:(NSTimeInterval)duration;

- (void)dismiss;

- (void)setStatus:(NSString*)string;
- (void)registerNotifications;
- (void)moveToPoint:(CGPoint)newCenter rotateAngle:(CGFloat)angle;
- (void)positionHUD:(NSNotification*)notification;
- (NSTimeInterval)displayDurationForString:(NSString*)string;

#if __IPHONE_OS_VERSION_MIN_REQUIRED < 50000
- (UIColor *)hudBackgroundColor;
- (UIColor *)hudForegroundColor;
- (UIColor *)hudStatusShadowColor;
- (UIFont *)hudFont;
- (UIImage *)hudSuccessImage;
- (UIImage *)hudErrorImage;
#endif

@end


@implementation SVProgressHUD

@synthesize overlayView, hudView, maskType, fadeOutTimer, stringLabel, imageView, spinnerView, visibleKeyboardHeight;
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 50000
@synthesize hudBackgroundColor = _uiHudBgColor;
@synthesize hudForegroundColor = _uiHudFgColor;
@synthesize hudStatusShadowColor = _uiHudStatusShColor;
@synthesize hudFont = _uiHudFont;
@synthesize hudSuccessImage = _uiHudSuccessImage;
@synthesize hudErrorImage = _uiHudErrorImage;
#endif


+ (SVProgressHUD*)sharedView {
    static dispatch_once_t once;
    static SVProgressHUD *sharedView;
    dispatch_once(&once, ^ { sharedView = [[self alloc] initWithFrame:[[UIScreen mainScreen] bounds]]; });
    return sharedView;
}


+ (void)setStatus:(NSString *)string {
	[[self sharedView] setStatus:string];
}

#pragma mark - Show Methods

+ (void)show {
    [[self sharedView] showProgress:-1 status:nil maskType:SVProgressHUDMaskTypeNone];
}

+ (void)showWithStatus:(NSString *)status {
    [[self sharedView] showProgress:-1 status:status maskType:SVProgressHUDMaskTypeNone];
}

+ (void)showWithMaskType:(SVProgressHUDMaskType)maskType {
    [[self sharedView] showProgress:-1 status:nil maskType:maskType];
}

+ (void)showWithStatus:(NSString*)status maskType:(SVProgressHUDMaskType)maskType {
    [[self sharedView] showProgress:-1 status:status maskType:maskType];
}

+ (void)showProgress:(CGFloat)progress {
    [[self sharedView] showProgress:progress status:nil maskType:SVProgressHUDMaskTypeNone];
}

+ (void)showProgress:(CGFloat)progress status:(NSString *)status {
    [[self sharedView] showProgress:progress status:status maskType:SVProgressHUDMaskTypeNone];
}

+ (void)showProgress:(CGFloat)progress status:(NSString *)status maskType:(SVProgressHUDMaskType)maskType {
    [[self sharedView] showProgress:progress status:status maskType:maskType];
}

#pragma mark - Show then dismiss methods

+ (void)showSuccessWithStatus:(NSString *)string {
    [self showImage:[[self sharedView] hudSuccessImage] status:string];
}

+ (void)showErrorWithStatus:(NSString *)string {
    [self showImage:[[self sharedView] hudErrorImage] status:string];
}

+ (void)showImage:(UIImage *)image status:(NSString *)string {
    NSTimeInterval displayInterval = [[SVProgressHUD sharedView] displayDurationForString:string];
    [[self sharedView] showImage:image status:string duration:displayInterval];
}


#pragma mark - Dismiss Methods

+ (void)popActivity {
    [self sharedView].activityCount--;
    if([self sharedView].activityCount == 0)
        [[self sharedView] dismiss];
}

+ (void)dismiss {
	[[self sharedView] dismiss];
}


#pragma mark - Instance Methods

- (id)initWithFrame:(CGRect)frame {
	
    if ((self = [super initWithFrame:frame])) {
		self.userInteractionEnabled = NO;
        self.backgroundColor = [UIColor clearColor];
		self.alpha = 0;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.activityCount = 0;
    }
	
    return self;
}

- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    switch (self.maskType) {
            
        case SVProgressHUDMaskTypeBlack: {
            [[UIColor colorWithWhite:0 alpha:0.5] set];
            CGContextFillRect(context, self.bounds);
            break;
        }
            
        case SVProgressHUDMaskTypeGradient: {
            
            size_t locationsCount = 2;
            CGFloat locations[2] = {0.0f, 1.0f};
            CGFloat colors[8] = {0.0f,0.0f,0.0f,0.0f,0.0f,0.0f,0.0f,0.75f}; 
            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
            CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, locations, locationsCount);
            CGColorSpaceRelease(colorSpace);
            
            CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
            float radius = MIN(self.bounds.size.width , self.bounds.size.height) ;
            CGContextDrawRadialGradient (context, gradient, center, 0, center, radius, kCGGradientDrawsAfterEndLocation);
            CGGradientRelease(gradient);
            
            break;
        }
    }
}

- (void)updatePosition {
	
    CGFloat hudWidth = 100;
    CGFloat hudHeight = 100;
    CGFloat stringWidth = 0;
    CGFloat stringHeight = 0;
    CGRect labelRect = CGRectZero;
    
    NSString *string = self.stringLabel.text;
    // False if it's text-only
    BOOL imageUsed = (self.imageView.image) || (self.imageView.hidden);
    
    if(string) {
        CGSize stringSize = [string sizeWithFont:self.stringLabel.font constrainedToSize:CGSizeMake(200, 300)];
        stringWidth = stringSize.width;
        stringHeight = stringSize.height;
        if (imageUsed)
            hudHeight = 80+stringHeight;
        else
            hudHeight = 20+stringHeight;
        
        if(stringWidth > hudWidth)
            hudWidth = ceil(stringWidth/2)*2;
        
        CGFloat labelRectY = imageUsed ? 66 : 9;
        
        if(hudHeight > 100) {
            labelRect = CGRectMake(12, labelRectY, hudWidth, stringHeight);
            hudWidth+=24;
        } else {
            hudWidth+=24;
            labelRect = CGRectMake(0, labelRectY, hudWidth, stringHeight);
        }
    }
	
	self.hudView.bounds = CGRectMake(0, 0, hudWidth, hudHeight);
	
    if(string)
        self.imageView.center = CGPointMake(CGRectGetWidth(self.hudView.bounds)/2, 36);
	else
       	self.imageView.center = CGPointMake(CGRectGetWidth(self.hudView.bounds)/2, CGRectGetHeight(self.hudView.bounds)/2);
	
	self.stringLabel.hidden = NO;
	self.stringLabel.frame = labelRect;
	
	if(string) {
		self.spinnerView.center = CGPointMake(ceil(CGRectGetWidth(self.hudView.bounds)/2)+0.5, 40.5);
        
        if(self.progress != -1)
            self.backgroundRingLayer.position = self.ringLayer.position = CGPointMake((CGRectGetWidth(self.hudView.bounds)/2), 36);
	}
    else {
		self.spinnerView.center = CGPointMake(ceil(CGRectGetWidth(self.hudView.bounds)/2)+0.5, ceil(self.hudView.bounds.size.height/2)+0.5);
        
        if(self.progress != -1)
            self.backgroundRingLayer.position = self.ringLayer.position = CGPointMake((CGRectGetWidth(self.hudView.bounds)/2), CGRectGetHeight(self.hudView.bounds)/2);
    }
    
}

- (void)setStatus:(NSString *)string {
    
	self.stringLabel.text = string;
    [self updatePosition];
    
}

- (void)setFadeOutTimer:(NSTimer *)newTimer {
    
    if(fadeOutTimer)
        [fadeOutTimer invalidate], fadeOutTimer = nil;
    
    if(newTimer)
        fadeOutTimer = newTimer;
}


- (void)registerNotifications {
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
}


- (void)positionHUD:(NSNotification*)notification {
    
    CGFloat keyboardHeight;
    double animationDuration;
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if(notification) {
        NSDictionary* keyboardInfo = [notification userInfo];
        CGRect keyboardFrame = [[keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
        animationDuration = [[keyboardInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        
        if(notification.name == UIKeyboardWillShowNotification || notification.name == UIKeyboardDidShowNotification) {
            if(UIInterfaceOrientationIsPortrait(orientation))
                keyboardHeight = keyboardFrame.size.height;
            else
                keyboardHeight = keyboardFrame.size.width;
        } else
            keyboardHeight = 0;
    } else {
        keyboardHeight = self.visibleKeyboardHeight;
    }
    
    CGRect orientationFrame = [UIScreen mainScreen].bounds;
    CGRect statusBarFrame = [UIApplication sharedApplication].statusBarFrame;
    
    if(UIInterfaceOrientationIsLandscape(orientation)) {
        float temp = orientationFrame.size.width;
        orientationFrame.size.width = orientationFrame.size.height;
        orientationFrame.size.height = temp;
        
        temp = statusBarFrame.size.width;
        statusBarFrame.size.width = statusBarFrame.size.height;
        statusBarFrame.size.height = temp;
    }
    
    CGFloat activeHeight = orientationFrame.size.height;
    
    if(keyboardHeight > 0)
        activeHeight += statusBarFrame.size.height*2;
    
    activeHeight -= keyboardHeight;
    CGFloat posY = floor(activeHeight*0.45);
    CGFloat posX = orientationFrame.size.width/2;
    
    CGPoint newCenter;
    CGFloat rotateAngle;
    
    switch (orientation) { 
        case UIInterfaceOrientationPortraitUpsideDown:
            rotateAngle = M_PI; 
            newCenter = CGPointMake(posX, orientationFrame.size.height-posY);
            break;
        case UIInterfaceOrientationLandscapeLeft:
            rotateAngle = -M_PI/2.0f;
            newCenter = CGPointMake(posY, posX);
            break;
        case UIInterfaceOrientationLandscapeRight:
            rotateAngle = M_PI/2.0f;
            newCenter = CGPointMake(orientationFrame.size.height-posY, posX);
            break;
        default: // as UIInterfaceOrientationPortrait
            rotateAngle = 0.0;
            newCenter = CGPointMake(posX, posY);
            break;
    } 
    
    if(notification) {
        SVProgressHUD *__weak weakSelf=self;
        [UIView animateWithDuration:animationDuration 
                              delay:0 
                            options:UIViewAnimationOptionAllowUserInteraction 
                         animations:^{
                             [weakSelf moveToPoint:newCenter rotateAngle:rotateAngle];
                         } completion:NULL];
    } 
    
    else {
        [self moveToPoint:newCenter rotateAngle:rotateAngle];
    }
    
}

- (void)moveToPoint:(CGPoint)newCenter rotateAngle:(CGFloat)angle {
    self.hudView.transform = CGAffineTransformMakeRotation(angle); 
    self.hudView.center = newCenter;
}

- (void)overlayViewDidReceiveTouchEvent {
    [[NSNotificationCenter defaultCenter] postNotificationName:SVProgressHUDDidReceiveTouchEventNotification object:nil];
}

#pragma mark - Master show/dismiss methods

- (void)showProgress:(float)progress status:(NSString*)string maskType:(SVProgressHUDMaskType)hudMaskType {
    
    if(!self.overlayView.superview){
        NSEnumerator *frontToBackWindows = [[[UIApplication sharedApplication]windows]reverseObjectEnumerator];
        
        for (UIWindow *window in frontToBackWindows)
            if (window.windowLevel == UIWindowLevelNormal) {
                [window addSubview:self.overlayView];
                break;
            }
    }
    
    if(!self.superview)
        [self.overlayView addSubview:self];
    
    self.fadeOutTimer = nil;
    self.imageView.hidden = YES;
    self.maskType = hudMaskType;
    self.progress = progress;
    
    self.stringLabel.text = string;
    [self updatePosition];
    
    if(progress >= 0) {
        self.imageView.image = nil;
        self.imageView.hidden = NO;
        [self.spinnerView stopAnimating];
        self.ringLayer.strokeEnd = progress;
        
        if(progress == 0)
            self.activityCount++;
    }
    else {
        self.activityCount++;
        [self cancelRingLayerAnimation];
        [self.spinnerView startAnimating];
    }
    
    if(self.maskType != SVProgressHUDMaskTypeNone) {
        self.overlayView.userInteractionEnabled = YES;
        self.accessibilityLabel = string;
        self.isAccessibilityElement = YES;
    }
    else {
        self.overlayView.userInteractionEnabled = NO;
        self.hudView.accessibilityLabel = string;
        self.hudView.isAccessibilityElement = YES;
    }

    [self.overlayView setHidden:NO];
    [self positionHUD:nil];
    
    if(self.alpha != 1) {
        [self registerNotifications];
        self.hudView.transform = CGAffineTransformScale(self.hudView.transform, 1.3, 1.3);
        SVProgressHUD *__weak weakSelf=self;
        [UIView animateWithDuration:0.15
                              delay:0
                            options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             weakSelf.hudView.transform = CGAffineTransformScale(self.hudView.transform, 1/1.3, 1/1.3);
                             weakSelf.alpha = 1;
                         }
                         completion:^(BOOL finished){
                             UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
                             UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, string);
                         }];
        
        [self setNeedsDisplay];
    }
}


- (void)showImage:(UIImage *)image status:(NSString *)string duration:(NSTimeInterval)duration {
    self.progress = -1;
    [self cancelRingLayerAnimation];
    
    if(![self.class isVisible])
        [self.class show];
    
    self.imageView.image = image;
    self.imageView.hidden = NO;
    self.stringLabel.text = string;
    [self updatePosition];
    [self.spinnerView stopAnimating];
    
    if(self.maskType != SVProgressHUDMaskTypeNone) {
        self.accessibilityLabel = string;
        self.isAccessibilityElement = YES;
    } else {
        self.hudView.accessibilityLabel = string;
        self.hudView.isAccessibilityElement = YES;
    }

    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
    UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, string);
    
    self.fadeOutTimer = [NSTimer timerWithTimeInterval:duration target:self selector:@selector(dismiss) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:self.fadeOutTimer forMode:NSRunLoopCommonModes];
}

- (void)dismiss {
    NSDictionary *notificationUserInfo = (self.stringLabel.text ? @{SVProgressHUDStatusUserInfoKey : self.stringLabel.text} : nil);
    [[NSNotificationCenter defaultCenter] postNotificationName:SVProgressHUDWillDisappearNotification
                                                        object:nil
                                                      userInfo:notificationUserInfo];
    
    self.activityCount = 0;
     SVProgressHUD *__weak weakSelf=self;
    [UIView animateWithDuration:0.15
                          delay:0
                        options:UIViewAnimationCurveEaseIn | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         weakSelf.hudView.transform = CGAffineTransformScale(self.hudView.transform, 0.8, 0.8);
                         weakSelf.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         if(weakSelf.alpha == 0) {
                             [[NSNotificationCenter defaultCenter] removeObserver:weakSelf];
                             [weakSelf cancelRingLayerAnimation];
                             [hudView removeFromSuperview];
                             hudView = nil;
                             
                             [overlayView removeFromSuperview];
                             overlayView = nil;

                             UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);

                             [[NSNotificationCenter defaultCenter] postNotificationName:SVProgressHUDDidDisappearNotification
                                                                                 object:nil
                                                                               userInfo:notificationUserInfo];
                             
                             // uncomment to make sure UIWindow is gone from app.windows
                             //NSLog(@"%@", [UIApplication sharedApplication].windows);
                             //NSLog(@"keyWindow = %@", [UIApplication sharedApplication].keyWindow);
                         }
                     }];
}


#pragma mark -
#pragma mark Ring progress animation

- (CAShapeLayer *)ringLayer {
    if(!_ringLayer) {
        CGPoint center = CGPointMake(CGRectGetWidth(hudView.frame)/2, CGRectGetHeight(hudView.frame)/2);
        _ringLayer = [self createRingLayerWithCenter:center radius:SVProgressHUDRingRadius lineWidth:SVProgressHUDRingThickness color:[UIColor whiteColor]];
        [self.hudView.layer addSublayer:_ringLayer];
    }
    return _ringLayer;
}

- (CAShapeLayer *)backgroundRingLayer {
    if(!_backgroundRingLayer) {
        CGPoint center = CGPointMake(CGRectGetWidth(hudView.frame)/2, CGRectGetHeight(hudView.frame)/2);
        _backgroundRingLayer = [self createRingLayerWithCenter:center radius:SVProgressHUDRingRadius lineWidth:SVProgressHUDRingThickness color:[UIColor darkGrayColor]];
        _backgroundRingLayer.strokeEnd = 1;
        [self.hudView.layer addSublayer:_backgroundRingLayer];
    }
    return _backgroundRingLayer;
}

- (void)cancelRingLayerAnimation {
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [hudView.layer removeAllAnimations];
    
    _ringLayer.strokeEnd = 0.0f;
    if (_ringLayer.superlayer) {
        [_ringLayer removeFromSuperlayer];
    }
    _ringLayer = nil;
    
    if (_backgroundRingLayer.superlayer) {
        [_backgroundRingLayer removeFromSuperlayer];
    }
    _backgroundRingLayer = nil;
    
    [CATransaction commit];
}

- (CGPoint)pointOnCircleWithCenter:(CGPoint)center radius:(double)radius angleInDegrees:(double)angleInDegrees {
    float x = (float)(radius * cos(angleInDegrees * M_PI / 180)) + radius;
    float y = (float)(radius * sin(angleInDegrees * M_PI / 180)) + radius;
    return CGPointMake(x, y);
}


- (UIBezierPath *)createCirclePathWithCenter:(CGPoint)center radius:(CGFloat)radius sampleCount:(NSInteger)sampleCount {
    
    UIBezierPath *smoothedPath = [UIBezierPath bezierPath];
    CGPoint startPoint = [self pointOnCircleWithCenter:center radius:radius angleInDegrees:-90];
    
    [smoothedPath moveToPoint:startPoint];
    
    CGFloat delta = 360.0f/sampleCount;
    CGFloat angleInDegrees = -90;
    for (NSInteger i=1; i<sampleCount; i++) {
        angleInDegrees += delta;
        CGPoint point = [self pointOnCircleWithCenter:center radius:radius angleInDegrees:angleInDegrees];
        [smoothedPath addLineToPoint:point];
    }
    
    [smoothedPath addLineToPoint:startPoint];
    
    return smoothedPath;
}


- (CAShapeLayer *)createRingLayerWithCenter:(CGPoint)center radius:(CGFloat)radius lineWidth:(CGFloat)lineWidth color:(UIColor *)color {
    
    UIBezierPath *smoothedPath = [self createCirclePathWithCenter:center radius:radius sampleCount:72];
    
    CAShapeLayer *slice = [CAShapeLayer layer];
    slice.frame = CGRectMake(center.x-radius, center.y-radius, radius*2, radius*2);
    slice.fillColor = [UIColor clearColor].CGColor;
    slice.strokeColor = color.CGColor;
    slice.lineWidth = lineWidth;
    slice.lineCap = kCALineJoinBevel;
    slice.lineJoin = kCALineJoinBevel;
    slice.path = smoothedPath.CGPath;
    return slice;
}

#pragma mark - Utilities

+ (BOOL)isVisible {
    return ([self sharedView].alpha == 1);
}


#pragma mark - Getters

- (NSTimeInterval)displayDurationForString:(NSString*)string {
    return MIN((float)string.length*0.06 + 0.3, 5.0);
}

- (UIButton *)overlayView {
    if(!overlayView) {
        overlayView = [[UIButton alloc] initWithFrame:[UIScreen mainScreen].bounds];
        overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        overlayView.backgroundColor = [UIColor clearColor];
        [overlayView addTarget:self action:@selector(overlayViewDidReceiveTouchEvent) forControlEvents:UIControlEventTouchDown];
        [overlayView setBackgroundImage:[UIImage new] forState:UIControlStateNormal];
        [overlayView setBackgroundImage:[UIImage new] forState:UIControlStateDisabled];
    }
    return overlayView;
}

- (UIView *)hudView {
    if(!hudView) {
        hudView = [[UIView alloc] initWithFrame:CGRectZero];
        hudView.layer.cornerRadius = 10;
        hudView.layer.masksToBounds = YES;
        
        // UIAppearance is used when iOS >= 5.0
		hudView.backgroundColor = self.hudBackgroundColor;

        hudView.autoresizingMask = (UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin |
                                    UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin);
        
        [self addSubview:hudView];
    }
    return hudView;
}

- (UILabel *)stringLabel {
    if (stringLabel == nil) {
        stringLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		stringLabel.backgroundColor = [UIColor clearColor];
		stringLabel.adjustsFontSizeToFitWidth = YES;
		#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
			stringLabel.textAlignment = UITextAlignmentCenter;
		#else
			stringLabel.textAlignment = NSTextAlignmentCenter;
		#endif
		stringLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;

        // UIAppearance is used when iOS >= 5.0
		stringLabel.textColor = self.hudForegroundColor;
		stringLabel.font = self.hudFont;
		stringLabel.shadowColor = self.hudStatusShadowColor;

		stringLabel.shadowOffset = CGSizeMake(0, -1);
        stringLabel.numberOfLines = 0;
    }
    
    if(!stringLabel.superview)
        [self.hudView addSubview:stringLabel];
    
    return stringLabel;
}

- (UIImageView *)imageView {
    if (imageView == nil)
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
    
    if(!imageView.superview)
        [self.hudView addSubview:imageView];
    
    return imageView;
}

- (UIActivityIndicatorView *)spinnerView {
    if (spinnerView == nil) {
        spinnerView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		spinnerView.hidesWhenStopped = YES;
		spinnerView.bounds = CGRectMake(0, 0, 37, 37);
        
        if([spinnerView respondsToSelector:@selector(setColor:)]) // setColor is iOS 5+
            spinnerView.color = self.hudForegroundColor;
    }
    
    if(!spinnerView.superview)
        [self.hudView addSubview:spinnerView];
    
    return spinnerView;
}

- (CGFloat)visibleKeyboardHeight {
        
    UIWindow *keyboardWindow = nil;
    for (UIWindow *testWindow in [[UIApplication sharedApplication] windows]) {
        if(![[testWindow class] isEqual:[UIWindow class]]) {
            keyboardWindow = testWindow;
            break;
        }
    }
    
    for (__strong UIView *possibleKeyboard in [keyboardWindow subviews]) {
        if([possibleKeyboard isKindOfClass:NSClassFromString(@"UIPeripheralHostView")] || [possibleKeyboard isKindOfClass:NSClassFromString(@"UIKeyboard")])
            return possibleKeyboard.bounds.size.height;
    }
    
    return 0;
}

#pragma mark - UIAppearance getters

- (UIColor *)hudBackgroundColor {
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 50000
    if(_uiHudBgColor == nil) {
        _uiHudBgColor = [[[self class] appearance] hudBackgroundColor];
    }
    
    if(_uiHudBgColor != nil) {
        return _uiHudBgColor;
    }
#endif
    
    return [UIColor colorWithWhite:0 alpha:0.8];
}

- (UIColor *)hudForegroundColor {
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 50000
    if(_uiHudFgColor == nil) {
        _uiHudFgColor = [[[self class] appearance] hudForegroundColor];
    }
    
    if(_uiHudFgColor != nil) {
        return _uiHudFgColor;
    }
#endif
    
    return [UIColor whiteColor];
}

- (UIColor *)hudStatusShadowColor {
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 50000
    if(_uiHudStatusShColor == nil) {
        _uiHudStatusShColor = [[[self class] appearance] hudStatusShadowColor];
    }
    
    if(_uiHudStatusShColor != nil) {
        return _uiHudStatusShColor;
    }
#endif
 
    return [UIColor blackColor];
}

- (UIFont *)hudFont {
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 50000
    if(_uiHudFont == nil) {
        _uiHudFont = [[[self class] appearance] hudFont];
    }
    
    if(_uiHudFont != nil) {
        return _uiHudFont;
    }
#endif
    
    return [UIFont boldSystemFontOfSize:16];
}

- (UIImage *)hudSuccessImage {
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 50000
    if(_uiHudSuccessImage == nil) {
        _uiHudSuccessImage = [[[self class] appearance] hudSuccessImage];
    }

    if(_uiHudSuccessImage != nil) {
        return _uiHudSuccessImage;
    }
#endif

    return [UIImage imageNamed:@"SVProgressHUD.bundle/success.png"];
}

- (UIImage *)hudErrorImage {
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 50000
    if(_uiHudErrorImage == nil) {
        _uiHudErrorImage = [[[self class] appearance] hudErrorImage];
    }

    if(_uiHudErrorImage != nil) {
        return _uiHudErrorImage;
    }
#endif

    return [UIImage imageNamed:@"SVProgressHUD.bundle/error.png"];
}

@end
