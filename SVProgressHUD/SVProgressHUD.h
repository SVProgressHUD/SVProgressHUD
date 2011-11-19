//
//  SVProgressHUD.h
//
//  Created by Sam Vermette on 27.03.11.
//  Copyright 2011 Sam Vermette. All rights reserved.
//
//  https://github.com/samvermette/SVProgressHUD
//

#import <UIKit/UIKit.h>
#import <AvailabilityMacros.h>

// To disable SVProgressHUD's control of the network activity indicator by default,
// add -DSVPROGRESSHUD_DISABLE_NETWORK_INDICATOR to CFLAGS in build settings.

enum {
    SVProgressHUDMaskTypeNone = 1, // allow user interactions while HUD is displayed
    SVProgressHUDMaskTypeClear, // don't allow
    SVProgressHUDMaskTypeBlack, // don't allow and dim the UI in the back of the HUD
    SVProgressHUDMaskTypeGradient // don't allow and dim the UI with a a-la-alert-view bg gradient
};

typedef NSUInteger SVProgressHUDMaskType;

@interface SVProgressHUD : UIWindow

+ (void)show;
+ (void)showWithStatus:(NSString*)status;
+ (void)showWithStatus:(NSString*)status networkIndicator:(BOOL)show;
+ (void)showWithStatus:(NSString*)status maskType:(SVProgressHUDMaskType)maskType;
+ (void)showWithStatus:(NSString*)status maskType:(SVProgressHUDMaskType)maskType networkIndicator:(BOOL)show;
+ (void)showWithMaskType:(SVProgressHUDMaskType)maskType;
+ (void)showWithMaskType:(SVProgressHUDMaskType)maskType networkIndicator:(BOOL)show;

+ (void)showSuccessWithStatus:(NSString*)string;
+ (void)setStatus:(NSString*)string; // change the HUD loading status while it's showing

+ (void)dismiss; // simply dismiss the HUD with a fade+scale out animation
+ (void)dismissWithSuccess:(NSString*)successString; // also displays the success icon image
+ (void)dismissWithSuccess:(NSString*)successString afterDelay:(NSTimeInterval)seconds;
+ (void)dismissWithError:(NSString*)errorString; // also displays the error icon image
+ (void)dismissWithError:(NSString*)errorString afterDelay:(NSTimeInterval)seconds;

// deprecated Show methods: view and posY params will be ignored
+ (void)showInView:(UIView*)view DEPRECATED_ATTRIBUTE;
+ (void)showInView:(UIView*)view status:(NSString*)string DEPRECATED_ATTRIBUTE;
+ (void)showInView:(UIView*)view status:(NSString*)string networkIndicator:(BOOL)show DEPRECATED_ATTRIBUTE;
+ (void)showInView:(UIView*)view status:(NSString*)string networkIndicator:(BOOL)show posY:(CGFloat)posY DEPRECATED_ATTRIBUTE;
+ (void)showInView:(UIView*)view status:(NSString*)string networkIndicator:(BOOL)show posY:(CGFloat)posY maskType:(SVProgressHUDMaskType)maskType DEPRECATED_ATTRIBUTE;

@end
