//
//  SVProgressHUD.m
//
//  Created by Sam Vermette on 27.03.11.
//  Copyright 2011 Sam Vermette. All rights reserved.
//

#import "SVProgressHUD.h"
#import <QuartzCore/QuartzCore.h>


@interface SVProgressHUD ()

@property (nonatomic, retain) NSTimer *fadeOutTimer;
@property (nonatomic, retain) UILabel *stringLabel;
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UIActivityIndicatorView *spinnerView;

- (void)showInView:(UIView *)view status:(NSString *)string networkIndicator:(BOOL)show posY:(CGFloat)posY animated:(BOOL) animated;
- (void)setStatus:(NSString *)string;
- (void)dismiss;
- (void)dismissAnimated:(BOOL) animated;
- (void)dismissWithStatus:(NSString *)string error:(BOOL)error;

- (void)memoryWarning:(NSNotification*) notification;

@end

@implementation SVProgressHUD

@synthesize fadeOutTimer, stringLabel, imageView, spinnerView;

static SVProgressHUD *sharedView = nil;

+ (SVProgressHUD*)sharedView {
	
	if(sharedView == nil)
		sharedView = [[SVProgressHUD alloc] initWithFrame:CGRectZero];
	
	return sharedView;
}

+ (void)setStatus:(NSString *)string {
	[[SVProgressHUD sharedView] setStatus:string];
}

#pragma mark -
#pragma mark Show Methods


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
	
	if(!view)
		view = [UIApplication sharedApplication].keyWindow;
	
	if(posY == -1)
		posY = floor(CGRectGetHeight(view.bounds)/2)-100;

	[[SVProgressHUD sharedView] showInView:view status:string networkIndicator:show posY:posY animated:YES];
}

+ (void)showInView:(UIView*)view status:(NSString*)string networkIndicator:(BOOL)show posY:(CGFloat)posY animated:(BOOL) animated{
	[[SVProgressHUD sharedView] showInView:view status:string networkIndicator:show posY:posY animated:animated];
}

#pragma mark -
#pragma mark Dismiss Methods

+ (void)dismiss {
	[[SVProgressHUD sharedView] dismissAnimated:YES];
}

+ (void)dismissAnimated:(BOOL)animated{
    [[SVProgressHUD sharedView] dismissAnimated:animated];
}

+ (void)dismissWithSuccess:(NSString*)successString {
	[[SVProgressHUD sharedView] dismissWithStatus:successString error:NO];
}


+ (void)dismissWithError:(NSString*)errorString {
	[[SVProgressHUD sharedView] dismissWithStatus:errorString error:YES];
}

#pragma mark -
#pragma mark Instance Methods

- (void)dealloc {
	
	if(fadeOutTimer != nil)
		[fadeOutTimer invalidate], [fadeOutTimer release], fadeOutTimer = nil;
	
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame {
	
    if ((self = [super initWithFrame:frame])) {
		self.layer.cornerRadius = 10;
		self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
		self.userInteractionEnabled = NO;
		self.layer.opacity = 0;
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(memoryWarning:) 
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
    }
	
    return self;
}

- (void)setStatus:(NSString *)string {
	
	CGFloat stringWidth = [string sizeWithFont:self.stringLabel.font].width+28;
	
	if(stringWidth < 100)
		stringWidth = 100;
	
	self.bounds = CGRectMake(0, 0, ceil(stringWidth/2)*2, 100);
	
	self.imageView.center = CGPointMake(CGRectGetWidth(self.bounds)/2, 36);
	
	self.stringLabel.hidden = NO;
	self.stringLabel.text = string;
	self.stringLabel.frame = CGRectMake(0, 66, CGRectGetWidth(self.bounds), 20);
	
	if(string)
		self.spinnerView.center = CGPointMake(ceil(CGRectGetWidth(self.bounds)/2), 40);
	else
		self.spinnerView.center = CGPointMake(ceil(CGRectGetWidth(self.bounds)/2), ceil(self.bounds.size.height/2));
}


- (void)showInView:(UIView*)view status:(NSString*)string networkIndicator:(BOOL)show posY:(CGFloat)posY animated:(BOOL)animated {
	
	if(fadeOutTimer != nil)
		[fadeOutTimer invalidate], [fadeOutTimer release], fadeOutTimer = nil;
	
	if(show)
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	else
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	self.imageView.hidden = YES;
	
	[self setStatus:string];
	[spinnerView startAnimating];
	
	if(![sharedView isDescendantOfView:view]) {
		
		[view addSubview:sharedView];
	
		posY+=(CGRectGetHeight(self.bounds)/2);
		self.center = CGPointMake(CGRectGetWidth(self.superview.bounds)/2, posY);
		
        if (animated) {
            self.layer.transform = CATransform3DScale(CATransform3DMakeTranslation(0, 0, 0), 1.3, 1.3, 1);
            self.layer.opacity = 0.3;
            
            [UIView animateWithDuration:0.15
                                  delay:0
                                options:UIViewAnimationOptionAllowUserInteraction
                             animations:^{	
                                 self.layer.transform = CATransform3DScale(CATransform3DMakeTranslation(0, 0, 0), 1, 1, 1);
                                 self.layer.opacity = 1;
                             }
                             completion:nil];  
        }
	}
}

- (void)dismiss {
    [self dismissAnimated:YES];
}

- (void)dismissAnimated:(BOOL)animated {
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
	if (animated) {
        [UIView animateWithDuration:0.15
                              delay:0
                            options:UIViewAnimationCurveEaseIn | UIViewAnimationOptionAllowUserInteraction
                         animations:^{	
                             self.layer.transform = CATransform3DScale(CATransform3DMakeTranslation(0, 0, 0), 0.8, 0.8, 1.0);
                             self.layer.opacity = 0;
                         }
                         completion:^(BOOL finished){ [self removeFromSuperview]; }];
    }
    else [self removeFromSuperview];
}


- (void)dismissWithStatus:(NSString*)string error:(BOOL)error {
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	if(error)
		self.imageView.image = [UIImage imageNamed:@"svhud-error.png"];
	else
		self.imageView.image = [UIImage imageNamed:@"svhud-success.png"];
	
	self.imageView.hidden = NO;
	
	[self setStatus:string];
	
	[self.spinnerView stopAnimating];
    
	if(fadeOutTimer != nil)
		[fadeOutTimer invalidate], [fadeOutTimer release], fadeOutTimer = nil;
	
	fadeOutTimer = [[NSTimer scheduledTimerWithTimeInterval:0.9 target:self selector:@selector(dismiss) userInfo:nil repeats:NO] retain];
}

#pragma mark -
#pragma mark Getters

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
		[self addSubview:stringLabel];
		[stringLabel release];
    }
    
    return stringLabel;
}

- (UIImageView *)imageView {
    
    if (imageView == nil) {
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
		[self addSubview:imageView];
		[imageView release];
    }
    
    return imageView;
}

- (UIActivityIndicatorView *)spinnerView {
    
    if (spinnerView == nil) {
        spinnerView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		spinnerView.contentMode = UIViewContentModeTopLeft;
		spinnerView.hidesWhenStopped = YES;
		spinnerView.bounds = CGRectMake(0, 0, 36, 36);
		[self addSubview:spinnerView];
		[spinnerView release];
    }
    
    return spinnerView;
}

#pragma mark -
#pragma mark MemoryWarning

- (void)memoryWarning:(NSNotification *)notification {
	
    if (sharedView.superview == nil) {
        [sharedView release];
        sharedView = nil;
    }
}

@end
