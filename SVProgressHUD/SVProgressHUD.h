//
//  SVProgressHUD.h
//  SVProgressHUD, https://github.com/TransitApp/SVProgressHUD
//
//  Copyright (c) 2011-2014 Sam Vermette and contributors. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AvailabilityMacros.h>

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 70000

#define UI_APPEARANCE_SELECTOR

#endif

extern NSString * const SVProgressHUDDidReceiveTouchEventNotification;
extern NSString * const SVProgressHUDDidTouchDownInsideNotification;
extern NSString * const SVProgressHUDWillDisappearNotification;
extern NSString * const SVProgressHUDDidDisappearNotification;
extern NSString * const SVProgressHUDWillAppearNotification;
extern NSString * const SVProgressHUDDidAppearNotification;

extern NSString * const SVProgressHUDStatusUserInfoKey;

typedef NS_ENUM(NSInteger, SVProgressHUDStyle) {
    SVProgressHUDStyleLight,        // default style, white HUD with black text, HUD background will be blurred on iOS 8 and above
    SVProgressHUDStyleDark,         // black HUD and white text, HUD background will be blurred on iOS 8 and above
    SVProgressHUDStyleCustom        // uses the fore- and background color properties
};

typedef NS_ENUM(NSUInteger, SVProgressHUDMaskType) {
    SVProgressHUDMaskTypeNone = 1,  // default mask type, allow user interactions while HUD is displayed
    SVProgressHUDMaskTypeClear,     // don't allow user interactions
    SVProgressHUDMaskTypeBlack,     // don't allow user interactions and dim the UI in the back of the HUD, as on iOS 7 and above
    SVProgressHUDMaskTypeGradient   // don't allow user interactions and dim the UI with a a-la UIAlertView background gradient, as on iOS 6
};

typedef NS_ENUM(NSUInteger, SVProgressHUDAnimationType) {
    SVProgressHUDAnimationTypeFlat,     // default animation type, custom flat animation (indefinite animated ring)
    SVProgressHUDAnimationTypeNative    // iOS native UIActivityIndicatorView
};

@interface SVProgressHUD : UIView

#pragma mark - Customization

@property (assign, nonatomic) SVProgressHUDStyle defaultStyle UI_APPEARANCE_SELECTOR;                   // default is SVProgressHUDStyleLight
@property (assign, nonatomic) SVProgressHUDMaskType defaultMaskType UI_APPEARANCE_SELECTOR;             // default is SVProgressHUDMaskTypeNone
@property (assign, nonatomic) SVProgressHUDAnimationType defaultAnimationType UI_APPEARANCE_SELECTOR;   // default is SVProgressHUDAnimationTypeFlat
@property (assign, nonatomic) CGSize minimumSize UI_APPEARANCE_SELECTOR;        // default is CGSizeZero, can be used to avoid resizing for a larger message
@property (assign, nonatomic) CGFloat ringThickness UI_APPEARANCE_SELECTOR;     // default is 2 pt
@property (assign, nonatomic) CGFloat ringRadius UI_APPEARANCE_SELECTOR;        // default is 18 pt
@property (assign, nonatomic) CGFloat ringNoTextRadius UI_APPEARANCE_SELECTOR;  // default is 24 pt
@property (assign, nonatomic) CGFloat cornerRadius UI_APPEARANCE_SELECTOR;      // default is 14 pt
@property (strong, nonatomic) UIFont *font UI_APPEARANCE_SELECTOR;              // default is [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]
@property (strong, nonatomic) UIColor *backgroundColor UI_APPEARANCE_SELECTOR;  // default is [UIColor whiteColor]
@property (strong, nonatomic) UIColor *foregroundColor UI_APPEARANCE_SELECTOR;  // default is [UIColor blackColor]
@property (strong, nonatomic) UIImage *infoImage UI_APPEARANCE_SELECTOR;        // default is the bundled info image provided by Freepik
@property (strong, nonatomic) UIImage *successImage UI_APPEARANCE_SELECTOR;     // default is the bundled success image provided by Freepik
@property (strong, nonatomic) UIImage *errorImage UI_APPEARANCE_SELECTOR;       // default is the bundled error image provided by Freepik
@property (strong, nonatomic) UIView *viewForExtension UI_APPEARANCE_SELECTOR;  // default is nil, only used if #define SV_APP_EXTENSIONS is set
@property (assign, nonatomic) NSTimeInterval minimumDismissTimeInterval;        // default is 5.0 seconds

@property (assign, nonatomic) UIOffset offsetFromCenter UI_APPEARANCE_SELECTOR; // default is 0, 0

+ (void)setDefaultStyle:(SVProgressHUDStyle)style;                  // default is SVProgressHUDStyleLight
+ (void)setDefaultMaskType:(SVProgressHUDMaskType)maskType;         // default is SVProgressHUDMaskTypeNone
+ (void)setDefaultAnimationType:(SVProgressHUDAnimationType)type;   // default is SVProgressHUDAnimationTypeFlat
+ (void)setMinimumSize:(CGSize)minimumSize;                         // default is CGSizeZero, can be used to avoid resizing for a larger message
+ (void)setRingThickness:(CGFloat)ringThickness;                    // default is 2 pt
+ (void)setRingRadius:(CGFloat)radius;                              // default is 18 pt
+ (void)setRingNoTextRadius:(CGFloat)radius;                        // default is 24 pt
+ (void)setCornerRadius:(CGFloat)cornerRadius;                      // default is 14 pt
+ (void)setFont:(UIFont*)font;                                      // default is [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]
+ (void)setForegroundColor:(UIColor*)color;                         // default is [UIColor blackColor], only used for SVProgressHUDStyleCustom
+ (void)setBackgroundColor:(UIColor*)color;                         // default is [UIColor whiteColor], only used for SVProgressHUDStyleCustom
+ (void)setInfoImage:(UIImage*)image;                               // default is the bundled info image provided by Freepik
+ (void)setSuccessImage:(UIImage*)image;                            // default is the bundled success image provided by Freepik
+ (void)setErrorImage:(UIImage*)image;                              // default is the bundled error image provided by Freepik
+ (void)setViewForExtension:(UIView*)view;                          // default is nil, only used if #define SV_APP_EXTENSIONS is set
+ (void)setMinimumDismissTimeInterval:(NSTimeInterval)interval;     // default is 5.0 seconds

#pragma mark - Show Methods

+ (void)show;
+ (void)showWithMaskType:(SVProgressHUDMaskType)maskType __attribute__((deprecated("Use show and setDefaultMaskType: instead.")));
+ (void)showWithStatus:(NSString*)status;
+ (void)showWithStatus:(NSString*)status maskType:(SVProgressHUDMaskType)maskType __attribute__((deprecated("Use showWithStatus: and setDefaultMaskType: instead.")));

+ (void)showProgress:(float)progress;
+ (void)showProgress:(float)progress maskType:(SVProgressHUDMaskType)maskType __attribute__((deprecated("Use showProgress: and setDefaultMaskType: instead.")));
+ (void)showProgress:(float)progress status:(NSString*)status;
+ (void)showProgress:(float)progress status:(NSString*)status maskType:(SVProgressHUDMaskType)maskType __attribute__((deprecated("Use showProgress: and setDefaultMaskType: instead.")));

+ (void)setStatus:(NSString*)status; // change the HUD loading status while it's showing

// stops the activity indicator, shows a glyph + status, and dismisses the HUD a little bit later
+ (void)showInfoWithStatus:(NSString*)status;
+ (void)showInfoWithStatus:(NSString*)status maskType:(SVProgressHUDMaskType)maskType __attribute__((deprecated("Use showInfoWithStatus: and setDefaultMaskType: instead.")));
+ (void)showSuccessWithStatus:(NSString*)status;
+ (void)showSuccessWithStatus:(NSString*)status maskType:(SVProgressHUDMaskType)maskType __attribute__((deprecated("Use showSuccessWithStatus: and setDefaultMaskType: instead.")));
+ (void)showErrorWithStatus:(NSString*)status;
+ (void)showErrorWithStatus:(NSString*)status maskType:(SVProgressHUDMaskType)maskType __attribute__((deprecated("Use showErrorWithStatus: and setDefaultMaskType: instead.")));

// shows a image + status, use 28x28 white PNGs
+ (void)showImage:(UIImage*)image status:(NSString*)status;
+ (void)showImage:(UIImage*)image status:(NSString*)status maskType:(SVProgressHUDMaskType)maskType __attribute__((deprecated("Use showImage: and setDefaultMaskType: instead.")));

+ (void)setOffsetFromCenter:(UIOffset)offset;
+ (void)resetOffsetFromCenter;

+ (void)popActivity; // decrease activity count, if activity count == 0 the HUD is dismissed
+ (void)dismiss;
+ (void)dismissWithDelay:(NSTimeInterval)delay; // delayes the dismissal

+ (BOOL)isVisible;

+ (NSTimeInterval)displayDurationForString:(NSString*)string;

@end

