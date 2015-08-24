//
//  SVProgressHUD.h
//  SVProgressHUD, https://github.com/TransitApp/SVProgressHUD
//
//  Copyright (c) 2011-2014 Sam Vermette and contributors. All rights reserved.
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

typedef NS_ENUM(NSInteger, SVProgressHUDStyle) {
    SVProgressHUDStyleLight,        // default style, white HUD with black text, HUD background will be blurred on iOS 8 and above
    SVProgressHUDStyleDark          // black HUD and white text, HUD background will be blurred on iOS 8 and above
};

typedef NS_ENUM(NSUInteger, SVProgressHUDMaskType) {
    SVProgressHUDMaskTypeNone = 1,  // allow user interactions while HUD is displayed
    SVProgressHUDMaskTypeClear,     // don't allow user interactions
    SVProgressHUDMaskTypeBlack,     // don't allow user interactions and dim the UI in the back of the HUD, as on iOS 7 and above
    SVProgressHUDMaskTypeGradient   // don't allow user interactions and dim the UI with a a-la-alert-view background gradient, as on iOS 6
};

@interface SVProgressHUD : UIView

#pragma mark - Customization

+ (void)setDefaultStyle:(SVProgressHUDStyle)style;          // default is SVProgressHUDStyleLight
+ (void)setDefaultMaskType:(SVProgressHUDMaskType)maskType; // default is SVProgressHUDMaskTypeNone
+ (void)setRingThickness:(CGFloat)width;                    // default is 2 pt
+ (void)setFont:(UIFont*)font;                              // default is [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]
+ (void)setInfoImage:(UIImage*)image;                       // default is the bundled info image provided by Freepik
+ (void)setSuccessImage:(UIImage*)image;                    // default is the bundled success image provided by Freepik
+ (void)setErrorImage:(UIImage*)image;                      // default is the bundled error image provided by Freepik
+ (void)setViewForExtension:(UIView*)view;                  // default is nil, only used if #define SV_APP_EXTENSIONS is set

#pragma mark - Show Methods

+ (void)show;
+ (void)showWithStatus:(NSString*)status;

+ (void)showProgress:(float)progress;
+ (void)showProgress:(float)progress status:(NSString*)status;

+ (void)setStatus:(NSString*)string; // change the HUD loading status while it's showing

// stops the activity indicator, shows a glyph + status, and dismisses HUD a little bit later
+ (void)showInfoWithStatus:(NSString *)string;
+ (void)showSuccessWithStatus:(NSString*)string;
+ (void)showErrorWithStatus:(NSString *)string;

// shows a image + status, use 28x28 white PNGs
+ (void)showImage:(UIImage*)image status:(NSString*)status;

+ (void)setOffsetFromCenter:(UIOffset)offset;
+ (void)resetOffsetFromCenter;

+ (void)popActivity; // decrease activity count, if activity count == 0 the HUD is dismissed
+ (void)dismiss;

+ (BOOL)isVisible;

@end

