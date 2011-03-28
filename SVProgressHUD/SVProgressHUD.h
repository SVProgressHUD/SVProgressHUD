//
//  SVProgressHUD.h
//
//  Created by Sam Vermette on 27.03.11.
//  Copyright 2011 Sam Vermette. All rights reserved.
//

@interface SVProgressHUD : UIView {
	UILabel *stringLabel;
	UIImageView *imageView;
	UIActivityIndicatorView *spinnerView;
	NSTimer *fadeOutTimer;
}

+ (void)show; // HUD gets added to UIApplication's keyWindow, which doesn't reflect the current device orientation
+ (void)showInView:(UIView*)view;
+ (void)showInView:(UIView*)view status:(NSString*)string;
+ (void)showInView:(UIView*)view status:(NSString*)string networkIndicator:(BOOL)show;
+ (void)showInView:(UIView*)view status:(NSString*)string networkIndicator:(BOOL)show posY:(CGFloat)posY;

+ (void)setStatus:(NSString*)string;

+ (void)dismiss;
+ (void)dismissWithSuccess:(NSString*)successString;
+ (void)dismissWithError:(NSString*)errorString;

@end
