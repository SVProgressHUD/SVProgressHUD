//
//  ViewController.h
//  SVProgressHUD, https://github.com/TransitApp/SVProgressHUD
//
//  Copyright 2011-2014 Sam Vermette. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

- (IBAction)show;
- (IBAction)showWithStatus;

- (IBAction)dismiss;
- (IBAction)dismissInfo;
- (IBAction)dismissSuccess;
- (IBAction)dismissError;

@end

