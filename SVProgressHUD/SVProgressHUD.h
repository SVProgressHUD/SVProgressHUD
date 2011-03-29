//
//  SVProgressHUD.h
//
//  Created by Sam Vermette on 27.03.11.
//  Copyright 2011 Sam Vermette. All rights reserved.
//

@interface SVProgressHUD : UIView 

/* 
showInView:(UIView*)	-> the view you're adding the HUD to. By default, it's added to UIApplication's keyWindow, which doesn't reflect the current device orientation.
status:(NSString*)		-> a loading status for the HUD (different from the success and error messages)
networkIndicator:(BOOL)	-> whether or not the HUD also triggers the UIApplication's network activity indicator (default is YES)
posY:(CGFloat)			-> the vertical position of the HUD (default is (viewHeight/2)-50)
*/
 
+ (void)show;
+ (void)showInView:(UIView*)view;
+ (void)showInView:(UIView*)view status:(NSString*)string;
+ (void)showInView:(UIView*)view status:(NSString*)string networkIndicator:(BOOL)show;
+ (void)showInView:(UIView*)view status:(NSString*)string networkIndicator:(BOOL)show posY:(CGFloat)posY;

+ (void)setStatus:(NSString*)string; // change the HUD loading status while it's showing

+ (void)dismiss; // simply dismiss the HUD with a fade+scale out animation
+ (void)dismissWithSuccess:(NSString*)successString; // also displays the success icon image
+ (void)dismissWithError:(NSString*)errorString; // also displays the error icon image

@end
