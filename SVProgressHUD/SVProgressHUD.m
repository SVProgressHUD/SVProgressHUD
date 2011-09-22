//
//  SVProgressHUD.m
//
//  Created by Sam Vermette on 27.03.11.
//  Copyright 2011 Sam Vermette. All rights reserved.
//

#import "SVProgressHUD.h"
#import <QuartzCore/QuartzCore.h>

@interface SVProgressHUD ()

@property (nonatomic, readwrite) SVProgressHUDMaskType maskType;
@property (nonatomic, retain) NSTimer *fadeOutTimer;
@property (nonatomic, retain) UILabel *stringLabel;
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UIActivityIndicatorView *spinnerView;

- (void)showInView:(UIView*)view status:(NSString*)string networkIndicator:(BOOL)show posY:(CGFloat)posY maskType:(SVProgressHUDMaskType)hudMaskType;
- (void)setStatus:(NSString*)string;

- (void)dismiss;
- (void)dismissWithStatus:(NSString*)string error:(BOOL)error;
- (void)dismissWithStatus:(NSString*)string error:(BOOL)error afterDelay:(NSTimeInterval)seconds;

- (void)memoryWarning:(NSNotification*)notification;

@end


@implementation SVProgressHUD

@synthesize maskType, fadeOutTimer, stringLabel, imageView, spinnerView;

static SVProgressHUD *sharedView = nil;

+ (SVProgressHUD*)sharedView {
	
	if(sharedView == nil)
		sharedView = [[SVProgressHUD alloc] initWithFrame:CGRectZero];
	
	return sharedView;
}

+ (void)setStatus:(NSString *)string {
	[[SVProgressHUD sharedView] setStatus:string];
}


#pragma mark - Show Methods

+ (void)show {
	[SVProgressHUD showInView:nil status:nil];
}


+ (void)showInView:(UIView*)view {
	[SVProgressHUD showInView:view status:nil];
}


+ (void)showInView:(UIView*)view status:(NSString*)string {
	[SVProgressHUD showInView:view status:string networkIndicator:YES];
}


+ (void)showInView:(UIView*)view status:(NSString*)string networkIndicator:(BOOL)show {
	[SVProgressHUD showInView:view status:string networkIndicator:show posY:-1];
}

+ (void)showInView:(UIView*)view status:(NSString*)string networkIndicator:(BOOL)show posY:(CGFloat)posY {
    [SVProgressHUD showInView:view status:string networkIndicator:show posY:posY maskType:SVProgressHUDMaskTypeNone];
}


+ (void)showInView:(UIView*)view status:(NSString*)string networkIndicator:(BOOL)show posY:(CGFloat)posY maskType:(SVProgressHUDMaskType)hudMaskType {
	
    BOOL addingToWindow = NO;
    
    if(!view) {
        UIWindow* keyWindow = [UIApplication sharedApplication].keyWindow;
        addingToWindow = YES;
        
        if ([keyWindow respondsToSelector:@selector(rootViewController)]) {
            //Use the rootViewController to reflect the device orientation
            view = keyWindow.rootViewController.view;
        }
        
        if(view == nil) 
            view = keyWindow;
    }
	
	if(posY == -1) {
		posY = floor(CGRectGetHeight(view.bounds)/2);
        
        if(addingToWindow)
            posY -= floor(CGRectGetHeight(view.bounds)/18); // move slightly towards the top
    }

	[[SVProgressHUD sharedView] showInView:view status:string networkIndicator:show posY:posY maskType:hudMaskType];
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

- (void)dealloc {
	
	if(fadeOutTimer != nil)
		[fadeOutTimer invalidate], [fadeOutTimer release], fadeOutTimer = nil;
	
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame {
	
    if ((self = [super initWithFrame:frame])) {
    
		self.userInteractionEnabled = NO;
        self.backgroundColor = [UIColor clearColor];
		self.alpha = 0;
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(memoryWarning:) 
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
        
        _hudView = [[UIView alloc] initWithFrame:CGRectZero];
        _hudView.layer.cornerRadius = 10;
		_hudView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
        _hudView.autoresizingMask = (UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin |
                                 UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin);
        
        [self addSubview:_hudView];
        [_hudView release];
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
    
	CGFloat stringWidth = [string sizeWithFont:self.stringLabel.font].width+28;
	
	if(stringWidth > hudWidth)
		hudWidth = ceil(stringWidth/2)*2;
	
	_hudView.bounds = CGRectMake(0, 0, hudWidth, 100);
	
	self.imageView.center = CGPointMake(CGRectGetWidth(_hudView.bounds)/2, 36);
	
	self.stringLabel.hidden = NO;
	self.stringLabel.text = string;
	self.stringLabel.frame = CGRectMake(0, 66, CGRectGetWidth(_hudView.bounds), 20);
	
	if(string)
		self.spinnerView.center = CGPointMake(ceil(CGRectGetWidth(_hudView.bounds)/2)+0.5, 40.5);
	else
		self.spinnerView.center = CGPointMake(ceil(CGRectGetWidth(_hudView.bounds)/2)+0.5, ceil(_hudView.bounds.size.height/2)+0.5);
}


- (void)showInView:(UIView*)view status:(NSString*)string networkIndicator:(BOOL)show posY:(CGFloat)posY maskType:(SVProgressHUDMaskType)hudMaskType {
	
	if(fadeOutTimer != nil)
		[fadeOutTimer invalidate], [fadeOutTimer release], fadeOutTimer = nil;
	
	if(show)
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	else
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	self.imageView.hidden = YES;
    self.maskType = hudMaskType;
	
	[self setStatus:string];
	[spinnerView startAnimating];
    
    if(self.maskType != SVProgressHUDMaskTypeNone)
        self.userInteractionEnabled = YES;
    else
        self.userInteractionEnabled = NO;

	if(![sharedView isDescendantOfView:view]) {
		self.alpha = 0;
		[view addSubview:sharedView];
	}
    
    self.frame = [UIApplication sharedApplication].keyWindow.frame;
	
	if(sharedView.layer.opacity != 1) {
		
        _hudView.center = CGPointMake(CGRectGetWidth(self.superview.bounds)/2, posY);
		_hudView.layer.transform = CATransform3DScale(CATransform3DMakeTranslation(0, 0, 0), 1.3, 1.3, 1);
		
		[UIView animateWithDuration:0.15
							  delay:0
							options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseOut
						 animations:^{	
							 _hudView.layer.transform = CATransform3DScale(CATransform3DMakeTranslation(0, 0, 0), 1, 1, 1);
                             self.alpha = 1;
						 }
						 completion:NULL];
	}
    
    [self setNeedsDisplay];
}


- (void)dismiss {
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	[UIView animateWithDuration:0.15
						  delay:0
						options:UIViewAnimationCurveEaseIn | UIViewAnimationOptionAllowUserInteraction
					 animations:^{	
						 _hudView.layer.transform = CATransform3DScale(CATransform3DMakeTranslation(0, 0, 0), 0.8, 0.8, 1.0);
						 self.alpha = 0;
					 }
					 completion:^(BOOL finished){ 
                         if(self.alpha == 0) {
                             [self removeFromSuperview]; 
                         }
                     }];
}


- (void)dismissWithStatus:(NSString*)string error:(BOOL)error {
	[self dismissWithStatus:string error:error afterDelay:0.9];
}


- (void)dismissWithStatus:(NSString *)string error:(BOOL)error afterDelay:(NSTimeInterval)seconds {
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

#pragma mark - Getters

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
		[_hudView addSubview:stringLabel];
		[stringLabel release];
    }
    
    return stringLabel;
}

- (UIImageView *)imageView {
    
    if (imageView == nil) {
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
		[_hudView addSubview:imageView];
		[imageView release];
    }
    
    return imageView;
}

- (UIActivityIndicatorView *)spinnerView {
    
    if (spinnerView == nil) {
        spinnerView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		spinnerView.hidesWhenStopped = YES;
		spinnerView.bounds = CGRectMake(0, 0, 37, 37);
		[_hudView addSubview:spinnerView];
		[spinnerView release];
    }
    
    return spinnerView;
}

#pragma mark - MemoryWarning

- (void)memoryWarning:(NSNotification *)notification {
	
    if (sharedView.superview == nil) {
        [sharedView release];
        sharedView = nil;
    }
}

@end
