//
//  ViewController.h
//  SVProgressHUD, https://github.com/TransitApp/SVProgressHUD
//
//  Copyright (c) 2011-2014 Sam Vermette. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

- (IBAction)show;
- (IBAction)showWithStatus;

- (IBAction)dismiss;
- (IBAction)showInfoWithStatus;
- (IBAction)showSuccessWithStatus;
- (IBAction)showErrorWithStatus;

- (IBAction)changeStyle:(id)sender;
- (IBAction)changeAnimationType:(id)sender;
- (IBAction)changeMaskType:(id)sender;

@end

