//
//  SVProgressHUD.h
//
//  Copyright 2011-2014 Sam Vermette. All rights reserved.
//
//  https://github.com/samvermette/SVProgressHUD
//

#import <UIKit/UIKit.h>
#import <AvailabilityMacros.h>

extern NSString * const SVProgressHUDDidReceiveTouchEventNotification;
extern NSString * const SVProgressHUDDidTouchDownInsideNotification;
extern NSString * const SVProgressHUDWillDisappearNotification;
extern NSString * const SVProgressHUDDidDisappearNotification;
extern NSString * const SVProgressHUDWillAppearNotification;
extern NSString * const SVProgressHUDDidAppearNotification;

extern NSString * const SVProgressHUDStatusUserInfoKey;

typedef NS_ENUM(NSUInteger, SVProgressHUDMaskType) {
    SVProgressHUDMaskTypeNone = 1,  // allow user interactions while HUD is displayed
    SVProgressHUDMaskTypeClear,     // don't allow user interactions
    SVProgressHUDMaskTypeBlack,     // don't allow user interactions and dim the UI in the back of the HUD
    SVProgressHUDMaskTypeGradient   // don't allow user interactions and dim the UI with a a-la-alert-view background gradient
};

@interface SVProgressHUD : UIView

#pragma mark - Customization

+ (void)setBackgroundColor:(UIColor*)color;                 // default is [UIColor whiteColor]
+ (void)setForegroundColor:(UIColor*)color;                 // default is [UIColor blackColor]
+ (void)setRingThickness:(CGFloat)width;                    // default is 4 pt
+ (void)setFont:(UIFont*)font;                              // default is [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]
+ (void)setSuccessImage:(UIImage*)image;                    // default is the bundled success image provided by Freepik
+ (void)setErrorImage:(UIImage*)image;                      // default is the bundled error image provided by Freepik
+ (void)setDefaultMaskType:(SVProgressHUDMaskType)maskType; // default is SVProgressHUDMaskTypeNone

#pragma mark - Show Methods

+ (void)show;
+ (void)showWithMaskType:(SVProgressHUDMaskType)maskType;
+ (void)showWithStatus:(NSString*)status;
+ (void)showWithStatus:(NSString*)status maskType:(SVProgressHUDMaskType)maskType;

+ (void)showProgress:(float)progress;
+ (void)showProgress:(float)progress maskType:(SVProgressHUDMaskType)maskType;
+ (void)showProgress:(float)progress status:(NSString*)status;
+ (void)showProgress:(float)progress status:(NSString*)status maskType:(SVProgressHUDMaskType)maskType;

+ (void)setStatus:(NSString*)string; // change the HUD loading status while it's showing

// stops the activity indicator, shows a glyph + status, and dismisses HUD a little bit later
+ (void)showSuccessWithStatus:(NSString*)string;
+ (void)showSuccessWithStatus:(NSString*)string maskType:(SVProgressHUDMaskType)maskType;

+ (void)showErrorWithStatus:(NSString *)string;
+ (void)showErrorWithStatus:(NSString *)string maskType:(SVProgressHUDMaskType)maskType;

// use 28x28 white pngs
+ (void)showImage:(UIImage*)image status:(NSString*)status;
+ (void)showImage:(UIImage*)image status:(NSString*)status maskType:(SVProgressHUDMaskType)maskType;

+ (void)setOffsetFromCenter:(UIOffset)offset;
+ (void)resetOffsetFromCenter;

+ (void)popActivity; // decrease activity count, if activity count == 0 the HUD is dismissed
+ (void)dismiss;

+ (BOOL)isVisible;

@end

