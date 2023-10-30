//
//  SVProgressHUD.h
//  SVProgressHUD, https://github.com/SVProgressHUD/SVProgressHUD
//
//  Copyright (c) 2011-2023 Sam Vermette and contributors. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AvailabilityMacros.h>

extern NSString * _Nonnull const SVProgressHUDDidReceiveTouchEventNotification;
extern NSString * _Nonnull const SVProgressHUDDidTouchDownInsideNotification;
extern NSString * _Nonnull const SVProgressHUDWillDisappearNotification;
extern NSString * _Nonnull const SVProgressHUDDidDisappearNotification;
extern NSString * _Nonnull const SVProgressHUDWillAppearNotification;
extern NSString * _Nonnull const SVProgressHUDDidAppearNotification;

extern NSString * _Nonnull const SVProgressHUDStatusUserInfoKey;

/// Represents the appearance style of the HUD.
typedef NS_ENUM(NSInteger, SVProgressHUDStyle) {
    /// White HUD with black text. HUD background will be blurred.
    SVProgressHUDStyleLight NS_SWIFT_NAME(light),
    
    /// Black HUD with white text. HUD background will be blurred.
    SVProgressHUDStyleDark NS_SWIFT_NAME(dark),
    
    /// Uses the fore- and background color properties.
    SVProgressHUDStyleCustom NS_SWIFT_NAME(custom),
    
    /// Automatically switch between light or dark mode appearance.
    SVProgressHUDStyleAutomatic NS_SWIFT_NAME(automatic)
};

/// Represents the type of mask to be applied when the HUD is displayed.
typedef NS_ENUM(NSUInteger, SVProgressHUDMaskType) {
    /// Allow user interactions while HUD is displayed.
    SVProgressHUDMaskTypeNone NS_SWIFT_NAME(none) = 1,
    
    /// Don't allow user interactions with background objects.
    SVProgressHUDMaskTypeClear NS_SWIFT_NAME(clear),
    
    /// Don't allow user interactions and dim the UI behind the HUD (as in iOS 7+).
    SVProgressHUDMaskTypeBlack NS_SWIFT_NAME(black),
    
    /// Don't allow user interactions and dim the UI with an UIAlertView-like background gradient (as in iOS 6).
    SVProgressHUDMaskTypeGradient NS_SWIFT_NAME(gradient),
    
    /// Don't allow user interactions and dim the UI behind the HUD with a custom color.
    SVProgressHUDMaskTypeCustom NS_SWIFT_NAME(custom)
};

/// Represents the animation type of the HUD when it's shown or hidden.
typedef NS_ENUM(NSUInteger, SVProgressHUDAnimationType) {
    /// Custom flat animation (indefinite animated ring).
    SVProgressHUDAnimationTypeFlat NS_SWIFT_NAME(flat),
    
    /// iOS native UIActivityIndicatorView.
    SVProgressHUDAnimationTypeNative NS_SWIFT_NAME(native)
};

typedef void (^SVProgressHUDShowCompletion)(void);
typedef void (^SVProgressHUDDismissCompletion)(void);

@interface SVProgressHUD : UIView

#pragma mark - Customization

/// Represents the default style for the HUD.
/// @discussion Default: SVProgressHUDStyleAutomatic.
@property (assign, nonatomic) SVProgressHUDStyle defaultStyle UI_APPEARANCE_SELECTOR;

/// Represents the type of mask applied when the HUD is displayed.
/// @discussion Default: SVProgressHUDMaskTypeNone.
@property (assign, nonatomic) SVProgressHUDMaskType defaultMaskType UI_APPEARANCE_SELECTOR;

/// Defines the animation type used when the HUD is displayed.
/// @discussion Default: SVProgressHUDAnimationTypeFlat.
@property (assign, nonatomic) SVProgressHUDAnimationType defaultAnimationType UI_APPEARANCE_SELECTOR;

/// The container view used for displaying the HUD. If nil, the default window level is used.
@property (strong, nonatomic, nullable) UIView *containerView;

/// The minimum size for the HUD. Useful for maintaining a consistent size when the message might cause resizing.
/// @discussion Default: CGSizeZero.
@property (assign, nonatomic) CGSize minimumSize UI_APPEARANCE_SELECTOR;

/// Thickness of the ring shown in the HUD.
/// @discussion Default: 2 pt.
@property (assign, nonatomic) CGFloat ringThickness UI_APPEARANCE_SELECTOR;

/// Radius of the ring shown in the HUD when there's associated text.
/// @discussion Default: 18 pt.
@property (assign, nonatomic) CGFloat ringRadius UI_APPEARANCE_SELECTOR;

/// Radius of the ring shown in the HUD when there's no associated text.
/// @discussion Default: 24 pt.
@property (assign, nonatomic) CGFloat ringNoTextRadius UI_APPEARANCE_SELECTOR;

/// Corner radius of the HUD view.
/// @discussion Default: 14 pt.
@property (assign, nonatomic) CGFloat cornerRadius UI_APPEARANCE_SELECTOR;

/// Font used for text within the HUD.
/// @discussion Default: [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline].
@property (strong, nonatomic, nonnull) UIFont *font UI_APPEARANCE_SELECTOR;

/// Background color of the HUD.
/// @discussion Default: [UIColor whiteColor].
@property (strong, nonatomic, nonnull) UIColor *backgroundColor UI_APPEARANCE_SELECTOR;

/// Foreground color used for content in the HUD.
/// @discussion Default: [UIColor blackColor].
@property (strong, nonatomic, nonnull) UIColor *foregroundColor UI_APPEARANCE_SELECTOR;

/// Color for any foreground images in the HUD.
/// @discussion Default: same as foregroundColor.
@property (strong, nonatomic, nullable) UIColor *foregroundImageColor UI_APPEARANCE_SELECTOR;

/// Color for the background layer behind the HUD.
/// @discussion Default: [UIColor colorWithWhite:0 alpha:0.4].
@property (strong, nonatomic, nonnull) UIColor *backgroundLayerColor UI_APPEARANCE_SELECTOR;

/// Size of any images displayed within the HUD.
/// @discussion Default: 28x28 pt.
@property (assign, nonatomic) CGSize imageViewSize UI_APPEARANCE_SELECTOR;

/// Indicates whether images within the HUD should be tinted.
/// @discussion Default: YES.
@property (assign, nonatomic) BOOL shouldTintImages UI_APPEARANCE_SELECTOR;

/// The image displayed when showing informational messages.
/// @discussion Default: info.circle from SF Symbols (iOS 13+) or the bundled info image provided by Freepik.
@property (strong, nonatomic, nonnull) UIImage *infoImage UI_APPEARANCE_SELECTOR;

/// The image displayed when showing success messages.
/// @discussion Default: checkmark from SF Symbols (iOS 13+) or the bundled success image provided by Freepik.
@property (strong, nonatomic, nonnull) UIImage *successImage UI_APPEARANCE_SELECTOR;

/// The image displayed when showing error messages.
/// @discussion Default: xmark from SF Symbols (iOS 13+) or the bundled error image provided by Freepik.
@property (strong, nonatomic, nonnull) UIImage *errorImage UI_APPEARANCE_SELECTOR;

/// A specific view for extensions. This property is only used if #define SV_APP_EXTENSIONS is set.
/// @discussion Default: nil.
@property (strong, nonatomic, nonnull) UIView *viewForExtension UI_APPEARANCE_SELECTOR;

/// The interval in seconds to wait before displaying the HUD. If the HUD is displayed before this time elapses, this timer is reset.
/// @discussion Default: 0 seconds.
@property (assign, nonatomic) NSTimeInterval graceTimeInterval;

/// The minimum amount of time in seconds the HUD will display.
/// @discussion Default: 5.0 seconds.
@property (assign, nonatomic) NSTimeInterval minimumDismissTimeInterval;

/// The maximum amount of time in seconds the HUD will display.
/// @discussion Default: CGFLOAT_MAX.
@property (assign, nonatomic) NSTimeInterval maximumDismissTimeInterval;

/// Offset from the center position, can be used to adjust the HUD position.
/// @discussion Default: 0, 0.
@property (assign, nonatomic) UIOffset offsetFromCenter UI_APPEARANCE_SELECTOR;

/// Duration of the fade-in animation when showing the HUD.
/// @discussion Default: 0.15.
@property (assign, nonatomic) NSTimeInterval fadeInAnimationDuration UI_APPEARANCE_SELECTOR;

/// Duration of the fade-out animation when hiding the HUD.
/// @discussion Default: 0.15.
@property (assign, nonatomic) NSTimeInterval fadeOutAnimationDuration UI_APPEARANCE_SELECTOR;

/// The maximum window level on which the HUD can be displayed.
/// @discussion Default: UIWindowLevelNormal.
@property (assign, nonatomic) UIWindowLevel maxSupportedWindowLevel;

/// Indicates if haptic feedback should be used.
/// @discussion Default: NO.
@property (assign, nonatomic) BOOL hapticsEnabled;

/// Indicates if motion effects should be applied to the HUD.
/// @discussion Default: YES.
@property (assign, nonatomic) BOOL motionEffectEnabled;

@property (class, strong, nonatomic, readonly, nonnull) NSBundle *imageBundle;

/// Sets the default style for the HUD.
/// @param style The desired style for the HUD.
+ (void)setDefaultStyle:(SVProgressHUDStyle)style;

/// Sets the default mask type for the HUD.
/// @param maskType The mask type to apply.
+ (void)setDefaultMaskType:(SVProgressHUDMaskType)maskType;

/// Sets the default animation type for the HUD.
/// @param type The desired animation type.
+ (void)setDefaultAnimationType:(SVProgressHUDAnimationType)type;

/// Sets the container view for the HUD.
/// @param containerView The view to contain the HUD.
+ (void)setContainerView:(nullable UIView*)containerView;

/// Sets the minimum size for the HUD.
/// @param minimumSize The minimum size for the HUD.
+ (void)setMinimumSize:(CGSize)minimumSize;

/// Sets the ring thickness for the HUD.
/// @param ringThickness Thickness of the ring.
+ (void)setRingThickness:(CGFloat)ringThickness;

/// Sets the ring radius for the HUD.
/// @param radius Radius of the ring.
+ (void)setRingRadius:(CGFloat)radius;

/// Sets the no text ring radius for the HUD.
/// @param radius Radius of the ring when no text is displayed.
+ (void)setRingNoTextRadius:(CGFloat)radius;

/// Sets the corner radius for the HUD.
/// @param cornerRadius Desired corner radius.
+ (void)setCornerRadius:(CGFloat)cornerRadius;

/// Sets the border color for the HUD.
/// @param color Desired border color.
+ (void)setBorderColor:(nonnull UIColor*)color;

/// Sets the border width for the HUD.
/// @param width Desired border width.
+ (void)setBorderWidth:(CGFloat)width;

/// Sets the font for the HUD's text.
/// @param font Desired font for the text.
+ (void)setFont:(nonnull UIFont*)font;

/// Sets the foreground color for the HUD.
/// @param color Desired foreground color.
/// @discussion These implicitly set the HUD's style to `SVProgressHUDStyleCustom`.
+ (void)setForegroundColor:(nonnull UIColor*)color;

/// Sets the foreground image color for the HUD.
/// @param color Desired color for the image.
/// @discussion These implicitly set the HUD's style to `SVProgressHUDStyleCustom`.
+ (void)setForegroundImageColor:(nullable UIColor*)color;

/// Sets the background color for the HUD.
/// @param color Desired background color.
/// @discussion These implicitly set the HUD's style to `SVProgressHUDStyleCustom`.
+ (void)setBackgroundColor:(nonnull UIColor*)color;

/// Sets a custom blur effect for the HUD view.
/// @param blurEffect Desired blur effect.
/// @discussion These implicitly set the HUD's style to `SVProgressHUDStyleCustom`.
+ (void)setHudViewCustomBlurEffect:(nullable UIBlurEffect*)blurEffect;

/// Sets the background layer color for the HUD.
/// @param color Desired color for the background layer.
+ (void)setBackgroundLayerColor:(nonnull UIColor*)color;

/// Sets the size for the HUD's image view.
/// @param size Desired size for the image view.
+ (void)setImageViewSize:(CGSize)size;

/// Determines if images should be tinted in the HUD.
/// @param shouldTintImages Whether images should be tinted.
+ (void)setShouldTintImages:(BOOL)shouldTintImages;

/// Sets the info image for the HUD.
/// @param image The desired info image.
+ (void)setInfoImage:(nonnull UIImage*)image;

/// Sets the success image for the HUD.
/// @param image The desired success image.
+ (void)setSuccessImage:(nonnull UIImage*)image;

/// Sets the error image for the HUD.
/// @param image The desired error image.
+ (void)setErrorImage:(nonnull UIImage*)image;

/// Sets the view for extensions.
/// @param view The desired view for extensions.
+ (void)setViewForExtension:(nonnull UIView*)view;

/// Sets the grace time interval for the HUD.
/// @param interval Desired grace time interval.
+ (void)setGraceTimeInterval:(NSTimeInterval)interval;

/// Sets the minimum dismiss time interval.
/// @param interval The minimum time interval, in seconds, that the HUD should be displayed.
+ (void)setMinimumDismissTimeInterval:(NSTimeInterval)interval;

/// Sets the maximum dismiss time interval.
/// @param interval The maximum time interval, in seconds, that the HUD should be displayed.
+ (void)setMaximumDismissTimeInterval:(NSTimeInterval)interval;

/// Sets the fade-in animation duration.
/// @param duration The duration, in seconds, for the fade-in animation.
+ (void)setFadeInAnimationDuration:(NSTimeInterval)duration;

/// Sets the fade-out animation duration.
/// @param duration The duration, in seconds, for the fade-out animation.
+ (void)setFadeOutAnimationDuration:(NSTimeInterval)duration;

/// Sets the max supported window level.
/// @param windowLevel The UIWindowLevel to which the HUD should be displayed.
+ (void)setMaxSupportedWindowLevel:(UIWindowLevel)windowLevel;

/// Determines if haptics are enabled.
/// @param hapticsEnabled A boolean that determines if haptic feedback is enabled.
+ (void)setHapticsEnabled:(BOOL)hapticsEnabled;

/// Determines if motion effect is enabled.
/// @param motionEffectEnabled A boolean that determines if motion effects are enabled.
+ (void)setMotionEffectEnabled:(BOOL)motionEffectEnabled;


#pragma mark - Show Methods

/// Shows the HUD without any additional status message.
+ (void)show;

/// Shows the HUD with a provided status message.
/// @param status The message to be displayed alongside the HUD.
+ (void)showWithStatus:(nullable NSString*)status;

/// Display methods to show progress on the HUD.

/// Shows the HUD with a progress indicator.
/// @param progress A float value between 0.0 and 1.0 indicating the progress.
+ (void)showProgress:(float)progress;

/// Shows the HUD with a progress indicator and a provided status message.
/// @param progress A float value between 0.0 and 1.0 indicating the progress.
/// @param status The message to be displayed alongside the progress indicator.
+ (void)showProgress:(float)progress status:(nullable NSString*)status;

/// Updates the current status of the loading HUD.
/// @param status The new status message to update the HUD with.
+ (void)setStatus:(nullable NSString*)status;

/// Shows an info status with the provided message.
/// @param status The info message to be displayed.
+ (void)showInfoWithStatus:(nullable NSString*)status;

/// Shows a success status with the provided message.
/// @param status The success message to be displayed.
+ (void)showSuccessWithStatus:(nullable NSString*)status;

/// Shows an error status with the provided message.
/// @param status The error message to be displayed.
+ (void)showErrorWithStatus:(nullable NSString*)status;

/// Shows a custom image with the provided status message.
/// @param image The custom image to be displayed.
/// @param status The message to accompany the custom image.
+ (void)showImage:(nonnull UIImage*)image status:(nullable NSString*)status;

/// Sets the offset from the center for the HUD.
/// @param offset The UIOffset value indicating how much the HUD should be offset from its center position.
+ (void)setOffsetFromCenter:(UIOffset)offset;

/// Resets the offset to center the HUD.
+ (void)resetOffsetFromCenter;

/// Decreases the activity count, dismissing the HUD if count reaches 0.
+ (void)popActivity;

/// Dismisses the HUD immediately.
+ (void)dismiss;

/// Dismisses the HUD and triggers a completion block.
/// @param completion A block that gets executed after the HUD is dismissed.
+ (void)dismissWithCompletion:(nullable SVProgressHUDDismissCompletion)completion;

/// Dismisses the HUD after a specified delay.
/// @param delay The time in seconds after which the HUD should be dismissed.
+ (void)dismissWithDelay:(NSTimeInterval)delay;

/// Dismisses the HUD after a specified delay and triggers a completion block.
/// @param delay The time in seconds after which the HUD should be dismissed.
/// @param completion A block that gets executed after the HUD is dismissed.
+ (void)dismissWithDelay:(NSTimeInterval)delay completion:(nullable SVProgressHUDDismissCompletion)completion;

/// Checks if the HUD is currently visible.
/// @return A boolean value indicating whether the HUD is visible.
+ (BOOL)isVisible;

/// Calculates the display duration based on a given string's length.
/// @param string The string whose length determines the display duration.
/// @return A time interval representing the display duration.
+ (NSTimeInterval)displayDurationForString:(nullable NSString*)string;

@end

