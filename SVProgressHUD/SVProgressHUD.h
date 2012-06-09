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

enum {
    SVProgressHUDMaskTypeNone = 1, // allow user interactions while HUD is displayed
    SVProgressHUDMaskTypeClear, // don't allow
    SVProgressHUDMaskTypeBlack, // don't allow and dim the UI in the back of the HUD
    SVProgressHUDMaskTypeGradient // don't allow and dim the UI with a a-la-alert-view bg gradient
};

typedef NSUInteger SVProgressHUDMaskType;

@interface SVProgressHUD : UIView

+ (void)show;
+ (void)showWithMaskType:(SVProgressHUDMaskType)maskType;

+ (void)showWithStatus:(NSString*)status;
+ (void)showWithStatus:(NSString*)status maskType:(SVProgressHUDMaskType)maskType;

+ (void)setStatus:(NSString*)string; // change the HUD loading status while it's showing

// stops the activity indicator, shows a glyph + status, and dismisses HUD 1s later
+ (void)showSuccessWithStatus:(NSString*)string;
+ (void)showErrorWithStatus:(NSString *)string;
+ (void)showImage:(UIImage*)image status:(NSString*)status; // use 28x28 white pngs

+ (void)dismiss;

+ (BOOL)isVisible;


// deprecated June 9th; custom durations encourages uncessarily long status strings (inappropriate, use UIAlertView instead)
+ (void)showSuccessWithStatus:(NSString *)string duration:(NSTimeInterval)duration DEPRECATED_ATTRIBUTE;
+ (void)showErrorWithStatus:(NSString *)string duration:(NSTimeInterval)duration DEPRECATED_ATTRIBUTE;

// deprecated June 9th; use the showWithSuccess/Error methods instead
+ (void)dismissWithSuccess:(NSString*)successString DEPRECATED_ATTRIBUTE; 
+ (void)dismissWithSuccess:(NSString*)successString afterDelay:(NSTimeInterval)seconds DEPRECATED_ATTRIBUTE;
+ (void)dismissWithError:(NSString*)errorString DEPRECATED_ATTRIBUTE;
+ (void)dismissWithError:(NSString*)errorString afterDelay:(NSTimeInterval)seconds DEPRECATED_ATTRIBUTE;


@end
