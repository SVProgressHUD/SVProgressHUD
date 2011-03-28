//
//  FCOverlayView.h
//  Shows
//
//  Created by Sam Vermette on 01.11.10.
//  Copyright 2010 Sam Vermette. All rights reserved.
//

@interface SVProgressHUD : UIView {
	UILabel *stringLabel;
	UIImageView *imageView;
	UIActivityIndicatorView *spinnerView;
	NSTimer *fadeOutTimer;
}

+ (void)show;
+ (void)showInView:(UIView*)view;
+ (void)showInView:(UIView*)view status:(NSString*)string;
+ (void)showInView:(UIView*)view status:(NSString*)string networkIndicator:(BOOL)b;
+ (void)showInView:(UIView*)view status:(NSString*)string networkIndicator:(BOOL)b posY:(CGFloat)posY;

+ (void)setStatus:(NSString*)string;

+ (void)dismiss;
+ (void)dismissWithSuccess:(NSString*)successString;
+ (void)dismissWithError:(NSString*)errorString;

@end
