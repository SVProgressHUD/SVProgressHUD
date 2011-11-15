//
//  SVProgressHUD.m
//
//  Created by Sam Vermette on 27.03.11.
//  Copyright 2011 Sam Vermette. All rights reserved.
//
//  https://github.com/samvermette/SVProgressHUD
//

#import "SVProgressHUD.h"
#import <QuartzCore/QuartzCore.h>

@interface SVProgressHUD ()

@property (nonatomic, readwrite) SVProgressHUDMaskType maskType;
@property (nonatomic, retain) NSTimer *fadeOutTimer;
@property (nonatomic, readonly) UIView *hudView;
@property (nonatomic, readonly) UILabel *stringLabel;
@property (nonatomic, readonly) UIImageView *imageView;
@property (nonatomic, readonly) UIActivityIndicatorView *spinnerView;
@property (nonatomic, assign) UIWindow *previousKeyWindow;
@property (nonatomic, readonly) CGFloat visibleKeyboardHeight;

- (void)showWithStatus:(NSString*)string maskType:(SVProgressHUDMaskType)hudMaskType networkIndicator:(BOOL)show;
- (void)setStatus:(NSString*)string;
- (void)registerNotifications;
- (void)positionHUD;

- (void)dismiss;
- (void)dismissWithStatus:(NSString*)string error:(BOOL)error;
- (void)dismissWithStatus:(NSString*)string error:(BOOL)error afterDelay:(NSTimeInterval)seconds;

- (void)memoryWarning:(NSNotification*)notification;

@end


@implementation SVProgressHUD

@synthesize hudView, maskType, fadeOutTimer, stringLabel, imageView, spinnerView, previousKeyWindow, visibleKeyboardHeight;

static SVProgressHUD *sharedView = nil;

- (void)dealloc {
	
	if(fadeOutTimer != nil)
		[fadeOutTimer invalidate], [fadeOutTimer release], fadeOutTimer = nil;
	
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [sharedView release];
    [hudView release];
    [stringLabel release];
    [imageView release];
    [spinnerView release];
    
    [super dealloc];
}

- (void)memoryWarning:(NSNotification *)notification {
	
    if(sharedView.superview == nil) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [sharedView release], sharedView = nil;
        [hudView release], hudView = nil;
        [stringLabel release], stringLabel = nil;
        [imageView release], imageView = nil;
        [spinnerView release], spinnerView = nil;
    }
}


+ (SVProgressHUD*)sharedView {
	
	if(sharedView == nil)
		sharedView = [[SVProgressHUD alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	return sharedView;
}


+ (void)setStatus:(NSString *)string {
	[[SVProgressHUD sharedView] setStatus:string];
}

#pragma mark - Show Methods

+ (void)show {
	[SVProgressHUD showWithStatus:nil networkIndicator:SVProgressHUDShowNetworkIndicator];
}

+ (void)showWithStatus:(NSString *)status {
    [SVProgressHUD showWithStatus:status networkIndicator:SVProgressHUDShowNetworkIndicator];
}

+ (void)showWithMaskType:(SVProgressHUDMaskType)maskType {
    [SVProgressHUD showWithStatus:nil maskType:maskType networkIndicator:SVProgressHUDShowNetworkIndicator];
}

+ (void)showWithStatus:(NSString*)status maskType:(SVProgressHUDMaskType)maskType {
    [SVProgressHUD showWithStatus:status maskType:maskType networkIndicator:SVProgressHUDShowNetworkIndicator];
}

+ (void)showWithStatus:(NSString *)status networkIndicator:(BOOL)show {
    [SVProgressHUD showWithStatus:status maskType:SVProgressHUDMaskTypeNone networkIndicator:show];
}

+ (void)showWithMaskType:(SVProgressHUDMaskType)maskType networkIndicator:(BOOL)show {
    [SVProgressHUD showWithStatus:nil maskType:maskType networkIndicator:show];
}

+ (void)showWithStatus:(NSString*)status maskType:(SVProgressHUDMaskType)maskType networkIndicator:(BOOL)show {
    [[SVProgressHUD sharedView] showWithStatus:status maskType:maskType networkIndicator:show];
}

+ (void)showSuccessWithStatus:(NSString *)string {
    [SVProgressHUD show];
    [SVProgressHUD dismissWithSuccess:string afterDelay:1];
}


#pragma mark - Deprecated show methods

+ (void)showInView:(UIView*)view {
    [SVProgressHUD showWithStatus:nil maskType:SVProgressHUDMaskTypeNone networkIndicator:SVProgressHUDShowNetworkIndicator];
}

+ (void)showInView:(UIView*)view status:(NSString*)string {
    [SVProgressHUD showWithStatus:string maskType:SVProgressHUDMaskTypeNone networkIndicator:SVProgressHUDShowNetworkIndicator];
}

+ (void)showInView:(UIView*)view status:(NSString*)string networkIndicator:(BOOL)show {
    [SVProgressHUD showWithStatus:string maskType:SVProgressHUDMaskTypeNone networkIndicator:show];
}

+ (void)showInView:(UIView*)view status:(NSString*)string networkIndicator:(BOOL)show posY:(CGFloat)posY {
    [SVProgressHUD showWithStatus:string maskType:SVProgressHUDMaskTypeNone networkIndicator:show];
}

+ (void)showInView:(UIView*)view status:(NSString*)string networkIndicator:(BOOL)show posY:(CGFloat)posY maskType:(SVProgressHUDMaskType)hudMaskType {
    [SVProgressHUD showWithStatus:string maskType:hudMaskType networkIndicator:show];    
}

#pragma mark - Dismiss Methods

+ (void)dismiss {
	[[SVProgressHUD sharedView] dismiss];
}

+ (void)dismissWithSuccess:(NSString*)successString {
	[[SVProgressHUD sharedView] dismissWithStatus:successString error:NO];
}

+ (void)dismissWithSuccess:(NSString *)successString afterDelay:(NSTimeInterval)seconds {
    [[SVProgressHUD sharedView] dismissWithStatus:successString error:NO afterDelay:seconds];
}

+ (void)dismissWithError:(NSString*)errorString {
	[[SVProgressHUD sharedView] dismissWithStatus:errorString error:YES];
}

+ (void)dismissWithError:(NSString *)errorString afterDelay:(NSTimeInterval)seconds {
    [[SVProgressHUD sharedView] dismissWithStatus:errorString error:YES afterDelay:seconds];
}


#pragma mark - Instance Methods

- (id)initWithFrame:(CGRect)frame {
	
    if ((self = [super initWithFrame:frame])) {
        self.windowLevel = UIWindowLevelAlert;
		self.userInteractionEnabled = NO;
        self.backgroundColor = [UIColor clearColor];
		self.alpha = 0;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
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

- (void)setStatus:(NSString *)string {
	
    CGFloat hudWidth = 100;
    CGFloat hudHeight = 100;
    CGFloat stringWidth = 0;
    CGFloat stringHeight = 0;
    CGRect labelRect = CGRectZero;
    
    if(string) {
        CGSize stringSize = [string sizeWithFont:self.stringLabel.font constrainedToSize:CGSizeMake(200, 300)];
        stringWidth = stringSize.width;
        stringHeight = stringSize.height;
        hudHeight = 80+stringHeight;
        
        if(stringWidth > hudWidth)
            hudWidth = ceil(stringWidth/2)*2;
        
        if(hudHeight > 100) {
            labelRect = CGRectMake(12, 66, hudWidth, stringHeight);
            hudWidth+=24;
        } else {
            hudWidth+=24;  
            labelRect = CGRectMake(0, 66, hudWidth, stringHeight);   
        }
    }
	
	self.hudView.bounds = CGRectMake(0, 0, hudWidth, hudHeight);
	
	self.imageView.center = CGPointMake(CGRectGetWidth(self.hudView.bounds)/2, 36);
	
	self.stringLabel.hidden = NO;
	self.stringLabel.text = string;
	self.stringLabel.frame = labelRect;
	
	if(string)
		self.spinnerView.center = CGPointMake(ceil(CGRectGetWidth(self.hudView.bounds)/2)+0.5, 40.5);
	else
		self.spinnerView.center = CGPointMake(ceil(CGRectGetWidth(self.hudView.bounds)/2)+0.5, ceil(self.hudView.bounds.size.height/2)+0.5);
}


- (void)showWithStatus:(NSString*)string maskType:(SVProgressHUDMaskType)hudMaskType networkIndicator:(BOOL)show {
    
	if(fadeOutTimer != nil)
		[fadeOutTimer invalidate], [fadeOutTimer release], fadeOutTimer = nil;
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = show;
	
	self.imageView.hidden = YES;
    self.maskType = hudMaskType;
	
	[self setStatus:string];
	[self.spinnerView startAnimating];
    
    if(self.maskType != SVProgressHUDMaskTypeNone)
        self.userInteractionEnabled = YES;
    else
        self.userInteractionEnabled = NO;
    
    if(![self isKeyWindow]) {
        self.previousKeyWindow = [UIApplication sharedApplication].keyWindow;
        [self makeKeyAndVisible];
    }
    
    [self positionHUD];
    
	if(self.alpha != 1) {
        [self registerNotifications];
		self.hudView.transform = CGAffineTransformScale(self.hudView.transform, 1.3, 1.3);
		
		[UIView animateWithDuration:0.15
							  delay:0
							options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseOut
						 animations:^{	
							 self.hudView.transform = CGAffineTransformScale(self.hudView.transform, 1/1.3, 1/1.3);
                             self.alpha = 1;
						 }
						 completion:NULL];
	}
    
    [self setNeedsDisplay];
}


- (void)registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(positionHUD) 
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification 
                                               object:nil];  
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(memoryWarning:) 
                                                 name:UIApplicationDidReceiveMemoryWarningNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(positionWithKeyboardNotification:) 
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(positionWithKeyboardNotification:) 
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
}

- (void)positionHUD {
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    CGRect orientationFrame = [UIScreen mainScreen].bounds;
    if(UIInterfaceOrientationIsLandscape(orientation)) {
        float temp = orientationFrame.size.width;
        orientationFrame.size.width = orientationFrame.size.height;
        orientationFrame.size.height = temp;
    }
    
    CGFloat posX = orientationFrame.size.width/2;
    
    CGFloat activeHeight = orientationFrame.size.height;
    
    if(self.visibleKeyboardHeight > 0)
        activeHeight += [UIApplication sharedApplication].statusBarFrame.size.height*2;
    
    activeHeight -= self.visibleKeyboardHeight;
    CGFloat posY = floor(activeHeight*0.45);
    
    switch (orientation) { 
        case UIInterfaceOrientationPortraitUpsideDown:
            self.hudView.transform = CGAffineTransformMakeRotation(M_PI); 
            self.hudView.center = CGPointMake(posX, orientationFrame.size.height-posY);
            break;
        case UIInterfaceOrientationLandscapeLeft:
            self.hudView.transform = CGAffineTransformMakeRotation(- M_PI / 2.0f);
            self.hudView.center = CGPointMake(posY, posX);
            break;
        case UIInterfaceOrientationLandscapeRight:
            self.hudView.transform = CGAffineTransformMakeRotation(M_PI / 2.0f);
            self.hudView.center = CGPointMake(orientationFrame.size.height-posY, posX);
            break;
        default: // as UIInterfaceOrientationPortrait
            self.hudView.transform = CGAffineTransformMakeRotation(0.0);
            self.hudView.center = CGPointMake(posX, posY);
            break;
    } 
}

- (void)positionWithKeyboardNotification:(NSNotification*)notification {
    NSDictionary* keyboardInfo = [notification userInfo];
    CGRect keyboardFrame = [[keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    double animationDuration = [[keyboardInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:animationDuration delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        if(notification.name == UIKeyboardWillHideNotification)
            self.hudView.frame = CGRectOffset(self.hudView.frame, 0, floor(keyboardFrame.size.height/2));
        else
            self.hudView.frame = CGRectOffset(self.hudView.frame, 0, 0-floor(keyboardFrame.size.height/2));
    } completion:NULL];
}


- (void)dismissWithStatus:(NSString*)string error:(BOOL)error {
	[self dismissWithStatus:string error:error afterDelay:0.9];
}


- (void)dismissWithStatus:(NSString *)string error:(BOOL)error afterDelay:(NSTimeInterval)seconds {
    
    if(self.alpha != 1)
        return;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	if(error)
		self.imageView.image = [UIImage imageNamed:@"SVProgressHUD.bundle/error.png"];
	else
		self.imageView.image = [UIImage imageNamed:@"SVProgressHUD.bundle/success.png"];
	
	self.imageView.hidden = NO;
	
	[self setStatus:string];
	
	[self.spinnerView stopAnimating];
    
	if(fadeOutTimer != nil)
		[fadeOutTimer invalidate], [fadeOutTimer release], fadeOutTimer = nil;
	
	fadeOutTimer = [[NSTimer scheduledTimerWithTimeInterval:seconds target:self selector:@selector(dismiss) userInfo:nil repeats:NO] retain];
}

- (void)dismiss {
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    __block SVProgressHUD *bSelf = sharedView;
	
	[UIView animateWithDuration:0.15
						  delay:0
						options:UIViewAnimationCurveEaseIn | UIViewAnimationOptionAllowUserInteraction
					 animations:^{	
						 bSelf.hudView.transform = CGAffineTransformScale(bSelf.hudView.transform, 0.8, 0.8);
						 bSelf.alpha = 0;
					 }
					 completion:^(BOOL finished){ 
                         if(bSelf.alpha == 0) {
                             [[NSNotificationCenter defaultCenter] removeObserver:bSelf];
                             [bSelf.previousKeyWindow makeKeyWindow];
                             [bSelf release], bSelf = nil;
                         }
                     }];
    
    sharedView = nil;
}

#pragma mark - Getters

- (UIView *)hudView {
    
    if(!hudView) {
        hudView = [[UIView alloc] initWithFrame:CGRectZero];
        hudView.layer.cornerRadius = 10;
		hudView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
        hudView.autoresizingMask = (UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin |
                                    UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin);
        
        [self addSubview:hudView];
    }
    
    return hudView;
}

- (UILabel *)stringLabel {
    
    if (stringLabel == nil) {
        stringLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		stringLabel.textColor = [UIColor whiteColor];
		stringLabel.backgroundColor = [UIColor clearColor];
		stringLabel.adjustsFontSizeToFitWidth = YES;
		stringLabel.textAlignment = UITextAlignmentCenter;
		stringLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
		stringLabel.font = [UIFont boldSystemFontOfSize:16];
		stringLabel.shadowColor = [UIColor blackColor];
		stringLabel.shadowOffset = CGSizeMake(0, -1);
        stringLabel.numberOfLines = 0;
		[self.hudView addSubview:stringLabel];
    }
    
    return stringLabel;
}

- (UIImageView *)imageView {
    
    if (imageView == nil) {
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
		[self.hudView addSubview:imageView];
    }
    
    return imageView;
}

- (UIActivityIndicatorView *)spinnerView {
    
    if (spinnerView == nil) {
        spinnerView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		spinnerView.hidesWhenStopped = YES;
		spinnerView.bounds = CGRectMake(0, 0, 37, 37);
		[self.hudView addSubview:spinnerView];
    }
    
    return spinnerView;
}

- (CGFloat)visibleKeyboardHeight {
    
    NSAutoreleasePool *autoreleasePool = [[NSAutoreleasePool alloc] init];
    
    UIWindow *keyboardWindow = nil;
    for (UIWindow *testWindow in [[UIApplication sharedApplication] windows]) {
        if (![[testWindow class] isEqual:[UIWindow class]]) {
            keyboardWindow = testWindow;
            break;
        }
    }
    
    // Locate UIKeyboard.  
    UIView *foundKeyboard = nil;
    for (UIView *possibleKeyboard in [keyboardWindow subviews]) {
        
        // iOS 4 sticks the UIKeyboard inside a UIPeripheralHostView.
        if ([[possibleKeyboard description] hasPrefix:@"<UIPeripheralHostView"]) {
            possibleKeyboard = [[possibleKeyboard subviews] objectAtIndex:0];
        }                                                                                
        
        if ([[possibleKeyboard description] hasPrefix:@"<UIKeyboard"]) {
            foundKeyboard = possibleKeyboard;
            break;
        }
    }
    
    [autoreleasePool release];
        
    if(foundKeyboard)
        return foundKeyboard.bounds.size.height;
    
    return 0;
}

@end
