//
//  ViewController.h
//  SVProgressHUD, https://github.com/SVProgressHUD/SVProgressHUD
//
//  Copyright (c) 2011-2016 Sam Vermette and contributors. All rights reserved.
//

#import <UIKit/UIKit.h>

//#define SV_APP_EXTENSIONS

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
