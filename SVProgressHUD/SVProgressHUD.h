//
//  SVProgressHUD.h
//
//  Created by Sam Vermette on 27.03.11.
//  Copyright 2011 Sam Vermette. All rights reserved.
//

typedef enum {
    SVProgressHUDMaskTypeNone, // allow user interactions while HUD is displayed
    SVProgressHUDMaskTypeClear, // don't allow
    SVProgressHUDMaskTypeBlack // don't allow and dim the UI in the back of the HUD
} SVProgressHUDMaskType;

@interface SVProgressHUD : UIView {
    UIView *_maskView;
}

/* 
showInView:(UIView*)                -> the view you're adding the HUD to. By default, it's added to the keyWindow rootViewController, or the keyWindow if the rootViewController is nil
status:(NSString*)                  -> a loading status for the HUD (different from the success and error messages)
networkIndicator:(BOOL)             -> whether or not the HUD also triggers the UIApplication's network activity indicator (default is YES)
posY:(CGFloat)                      -> the vertical position of the HUD (default is viewHeight/2-viewHeight/8)
maskType:(SVProgressHUDMaskType)    -> set whether to allow user interactions while HUD is displayed
*/
 
+ (void)show;
+ (void)showInView:(UIView*)view;
+ (void)showInView:(UIView*)view status:(NSString*)string;
+ (void)showInView:(UIView*)view status:(NSString*)string networkIndicator:(BOOL)show;
+ (void)showInView:(UIView*)view status:(NSString*)string networkIndicator:(BOOL)show posY:(CGFloat)posY;
+ (void)showInView:(UIView*)view status:(NSString*)string networkIndicator:(BOOL)show posY:(CGFloat)posY maskType:(SVProgressHUDMaskType)maskType;

+ (void)setStatus:(NSString*)string; // change the HUD loading status while it's showing

+ (void)dismiss; // simply dismiss the HUD with a fade+scale out animation
+ (void)dismissWithSuccess:(NSString*)successString; // also displays the success icon image
+ (void)dismissWithSuccess:(NSString*)successString afterDelay:(NSTimeInterval)seconds;
+ (void)dismissWithError:(NSString*)errorString; // also displays the error icon image
+ (void)dismissWithError:(NSString*)errorString afterDelay:(NSTimeInterval)seconds;

@end
